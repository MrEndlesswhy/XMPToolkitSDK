//
//  JPEGMetadataVistor.m
//  XMPToolkitSDK
//
//  Created by Evan Xie on 2018/9/30.
//  Copyright © 2018 GO6D. All rights reserved.
//

#import "JPEGMetadataVistor.h"
#include <string>

#define TXMP_STRING_TYPE std::string
#define XMP_INCLUDE_XMPFILES 1

#include "XMP.hpp"

#include <iostream>
#include <fstream>
#include <stdio.h>

#import "XMP.incl_cpp"

using namespace std;

@interface JPEGMetadataVistor ()
{
    XMPErrorCode _internalError;
    SXMPFiles _fileHandle;
    SXMPMeta _meta;
    
    bool _isMetadataWritable;
}
@end

@implementation JPEGMetadataVistor

SXMPMeta createXMPMetaFromRDF(const char *rdf) {
    SXMPMeta meta;
    // Loop over the rdf string and create the XMP object
    // 10 characters at a time
    int i;
    for (i = 0; i < (long)strlen(rdf) - 10; i += 10 ) {
        meta.ParseFromBuffer ( &rdf[i], 10, kXMP_ParseMoreBuffers );
    }
    
    // The last call has no kXMP_ParseMoreBuffers options, signifying
    // this is the last input buffer
    meta.ParseFromBuffer ( &rdf[i], (XMP_StringLen) strlen(rdf) - i );
    return meta;
}

- (instancetype)initWithJpegFilePath:(NSString *)imageFilePath
{
    if (self = [super init]) {
        if (!SXMPMeta::Initialize()) {
            NSLog(@"ERROR: SXMPMeta Initialize Fail");
            _internalError = XMPErrorCodeXMPSetupFailed;
            return self;
        }
        
        if (!SXMPFiles::Initialize()) {
            NSLog(@"ERROR: SXMPMeta Initialize Fail");
            _internalError = XMPErrorCodeXMPSetupFailed;
            return self;
        }
        
        XMP_OptionBits opts = kXMPFiles_OpenForUpdate | kXMPFiles_OpenUseSmartHandler;
        if (!_fileHandle.OpenFile(imageFilePath.UTF8String, kXMP_UnknownFile, opts)) {
            // Now try using packet scanning
            opts = kXMPFiles_OpenForUpdate | kXMPFiles_OpenUsePacketScanning;
            if(!_fileHandle.OpenFile(imageFilePath.UTF8String, kXMP_UnknownFile, opts)) {
                _internalError = XMPErrorCodeFileCanNotOpen;
            }
            return self;
        }
        
        _fileHandle.IsMetadataWritable(imageFilePath.UTF8String, &_isMetadataWritable);
        [self readMetaData];
    }
    return self;
}

- (void)dealloc
{
    SXMPFiles::Terminate();
    SXMPMeta::Terminate();
}

- (void)readMetaData
{
    _fileHandle.GetXMP(&_meta);
    string pktString;
    _meta.SerializeToBuffer(&pktString);
    cout << pktString << endl;
    
    bool exists;
    string simpleValue;
    exists = _meta.GetProperty( kXMP_NS_XMP, "CreatorTool", &simpleValue, NULL );
    if (exists) {
        cout << "CreatorTool = " << simpleValue << endl;
    } else {
        simpleValue.clear();
    }
    
    
    string elementValue;
    exists = _meta.GetArrayItem( kXMP_NS_DC, "creator", 1, &elementValue, NULL );
    if( exists )
        cout << "dc:creator = " << elementValue << endl;
    else
        elementValue.clear();
    
    string propValue;
    int arrSize = _meta.CountArrayItems( kXMP_NS_DC, "subject");
    for( int i = 1;i <= arrSize;i++ ){
        _meta.GetArrayItem( kXMP_NS_DC, "subject", i, &propValue, NULL );
        cout << "dc:subject[" << i << "] = " << propValue << endl;
    }
    
    string itemValue;
    _meta.GetLocalizedText( kXMP_NS_DC, "title", "en", "en-US", NULL,
                          &itemValue, NULL );
    cout << "dc:title in English = " << itemValue << endl;
    
    _meta.GetLocalizedText( kXMP_NS_DC, "title", "fr", "fr-FR", NULL, &itemValue, NULL );
    cout << "dc:title in French = " << itemValue << endl;
    
    XMP_DateTime myDate;
    if( _meta.GetProperty_Date( kXMP_NS_XMP, "MetadataDate", &myDate, NULL )){
        string myDateStr;
        SXMPUtils::ConvertFromDate( myDate, &myDateStr );
        cout << "meta:MetadataDate = " << myDateStr << endl;
    }
    
    bool exist;
    string pathF, value;
    exist = _meta.DoesStructFieldExist( kXMP_NS_EXIF, "Flash", kXMP_NS_EXIF,"Fired" );
    if( exist ){
        bool flashFired;
        SXMPUtils::ComposeStructFieldPath( kXMP_NS_EXIF, "Flash", kXMP_NS_EXIF,
                                          "Fired", &pathF );
        _meta.GetProperty_Bool( kXMP_NS_EXIF, pathF.c_str(), &flashFired, NULL );
        string flash = (flashFired) ? "True" : "False";
        cout << "Flash Used = " << flash << endl;
    }
}

- (void)setPanoramaMetadataWithWidth:(NSInteger)width height:(NSInteger)height captureSoftware:(NSString *)captureSoftware
{
    // Solution 1:
//    XMP_StringPtr scheme = "http://ns.google.com/photos/1.0/panorama/";
//    _meta.RegisterNamespace(scheme, "GPano", nil);
//    _meta.SetProperty_Bool(scheme, "GPano:UsePanoramaViewer", true);
//    _meta.SetProperty(scheme, "GPano:CaptureSoftware", captureSoftware.UTF8String);
//    _meta.SetProperty(scheme, "GPano:StitchingSoftware", captureSoftware.UTF8String);
//    _meta.SetProperty(scheme, "GPano:ProjectionType", "equirectangular");
//    _meta.SetProperty_Float(scheme, "GPano:PoseHeadingDegrees", 135.0);
//    _meta.SetProperty_Int(scheme, "GPano:CroppedAreaLeftPixels", 0);
//    _meta.SetProperty_Int(scheme, "GPano:CroppedAreaTopPixels", 0);
//    _meta.SetProperty_Int(scheme, "GPano:CroppedAreaImageWidthPixels", (int32_t)width);
//    _meta.SetProperty_Int(scheme, "GPano:CroppedAreaImageHeightPixels", (int32_t)height);
//    _meta.SetProperty_Int(scheme, "GPano:FullPanoWidthPixels", (int32_t)width);
//    _meta.SetProperty_Int(scheme, "GPano:FullPanoHeightPixels", (int32_t)height);
    
    // Soultion 2:
    // Append the newly created properties onto the original XMP object
    // This will:
    // a) Add ANY new TOP LEVEL properties in the source (rdfMeta) to the destination (meta)
    // b) Replace any top level properties in the source with the matching properties from the destination
    NSString *panoRDF = [self createPanoramaRDFStringWithWidth:width height:height captureSoftware:captureSoftware];
    SXMPMeta panoMeta = createXMPMetaFromRDF(panoRDF.UTF8String);
    SXMPUtils::ApplyTemplate(&_meta, panoMeta, kXMPTemplate_AddNewProperties | kXMPTemplate_ReplaceExistingProperties | kXMPTemplate_IncludeInternalProperties);
}

- (void)setMotionMetadataWithQuaternion:(simd_float4)motion
{
    // Append the newly created properties onto the original XMP object
    // This will:
    // a) Add ANY new TOP LEVEL properties in the source (rdfMeta) to the destination (meta)
    // b) Replace any top level properties in the source with the matching properties from the destination
    NSString *motionRDF = [self createMotionDataRDFStringWithQuaternion:motion];
    SXMPMeta motionMeta = createXMPMetaFromRDF(motionRDF.UTF8String);
    SXMPUtils::ApplyTemplate(&_meta, motionMeta, kXMPTemplate_AddNewProperties | kXMPTemplate_ReplaceExistingProperties | kXMPTemplate_IncludeInternalProperties);
}

- (XMPErrorCode)saveMetadataToFile
{
    if (!_fileHandle.CanPutXMP(_meta)) {
        _fileHandle.CloseFile();
        return XMPErrorCodeAddMetadataFailed;
    }
    _fileHandle.PutXMP(_meta);
    _fileHandle.CloseFile();
    return XMPErrorCodeOk;
}

//MARK: - Private Functions

- (NSString *)createPanoramaRDFStringWithWidth:(NSInteger)width height:(NSInteger)height captureSoftware:(NSString *)captureSoftware
{
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendString:@"<rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">\n"];
    [string appendString:@"<rdf:Description rdf:about=\"\" xmlns:GPano=\"http://ns.google.com/photos/1.0/panorama/\">\n"];
    [string appendString:@"    <GPano:UsePanoramaViewer>True</GPano:UsePanoramaViewer>\n"];
    [string appendFormat:@"    <GPano:CaptureSoftware>%@</GPano:CaptureSoftware>\n", captureSoftware];
    [string appendFormat:@"    <GPano:StitchingSoftware>%@</GPano:StitchingSoftware>\n", captureSoftware];
    [string appendString:@"    <GPano:ProjectionType>equirectangular</GPano:ProjectionType>\n"];
    [string appendString:@"    <GPano:PoseHeadingDegrees>135</GPano:PoseHeadingDegrees>\n"];
    [string appendString:@"    <GPano:CroppedAreaLeftPixels>0</GPano:CroppedAreaLeftPixels>\n"];
    [string appendString:@"    <GPano:CroppedAreaTopPixels>0</GPano:CroppedAreaTopPixels>\n"];
    [string appendFormat:@"    <GPano:CroppedAreaImageWidthPixels>%d</GPano:CroppedAreaImageWidthPixels>\n", (int32_t)width];
    [string appendFormat:@"    <GPano:CroppedAreaImageHeightPixels>%d</GPano:CroppedAreaImageHeightPixels>\n", (int32_t)height];
    [string appendFormat:@"    <GPano:FullPanoWidthPixels>%d</GPano:FullPanoWidthPixels>\n", (int32_t)width];
    [string appendFormat:@"    <GPano:FullPanoHeightPixels>%d</GPano:FullPanoHeightPixels>\n", (int32_t)height];
    [string appendString:@"</rdf:Description></rdf:RDF>"];
    return string;
}

- (NSString *)createMotionDataRDFStringWithQuaternion:(simd_float4)motion
{
    NSString *motionString = [NSString stringWithFormat:@"motion: %f,%f,%f,%f", motion.x, motion.y, motion.z, motion.w];
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendString:@"<rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">\n"];
    [string appendString:@"<rdf:Description rdf:about=\"\" xmlns:exif=\"http://ns.adobe.com/exif/1.0/\">\n"];
    [string appendFormat:@"    <exif:UserComment>%@</exif:UserComment>\n", motionString];
    [string appendString:@"</rdf:Description></rdf:RDF>"];
    return string;
}


@end
