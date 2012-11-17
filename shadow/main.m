//
//  main.m
//  shadow
//
//  Created by zarigani on 2012/11/15.
//  Copyright (c) 2012年 bebe工房. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern float const BBKAlphaLimit;
float const BBKAlphaLimit = 0.96;

// ディスプレイスケールを取得する  // NSLog(@"scale = %f", scale);  //例 Retina scale = 2.000000
CGFloat displayScale()
{
    // http://stackoverflow.com/questions/11344076/how-to-get-nsscreen-backingscalefactor-on-cocoa-targeting-10-6
    // building for the OS X 10.7 SDK, with the deployment target set to 10.6.
    if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)]) {
        return [ [NSScreen mainScreen] backingScaleFactor];
    }else{
        return 1.0;
    }
}

// 指定した値より透明なピクセルを透明度0（透過率100%）にした画像を返す
//      setColorは処理が遅い、よって巨大な画像では時間がかかる
NSImage* transparentImageByAlphaValue(NSImage* image)
{
    NSBitmapImageRep* imageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    NSColor *clearColor = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    for (int y=0; y<imageRep.pixelsHigh; y++) {
        for (int x=0; x<imageRep.pixelsWide; x++) {
            NSColor *color = [imageRep colorAtX:x y:y];
            if ([color alphaComponent] < BBKAlphaLimit) {
//                CGFloat a = [color alphaComponent];
//                CGFloat r = [color redComponent];
//                CGFloat g = [color greenComponent];
//                CGFloat b = [color blueComponent];
//                NSLog(@"(%i, %i) %f %f %f %f", x, y,a, r, g, b);
                [imageRep setColor:clearColor atX:x y:y];
            }
        }
    }
    CGImageRef cgimage = [imageRep CGImage];
    NSImage *transparentImage = [[NSImage alloc] initWithCGImage:cgimage size:NSZeroSize];
    return transparentImage;
}

// 左側の境界座標を返す
NSInteger trimLeft(NSBitmapImageRep *imageRep)
{
    for (int x=0; x<imageRep.pixelsWide; x++) {
        for (int y=0; y<imageRep.pixelsHigh; y++) {
            NSColor *color = [imageRep colorAtX:x y:y];
            if ([color alphaComponent] >= BBKAlphaLimit) return x;
        }
    }
    return 0;
}

// 右側の境界座標を返す
NSInteger trimRight(NSBitmapImageRep *imageRep)
{
    for (NSInteger x=imageRep.pixelsWide; x>=0; x--) {
        for (NSInteger y=0; y<imageRep.pixelsHigh; y++) {
            NSColor *color = [imageRep colorAtX:x y:y];
            if ([color alphaComponent] >= BBKAlphaLimit) return (x + 1);
        }
    }
    return 0;
}

// 上側の境界座標を返す
NSInteger trimTop(NSBitmapImageRep *imageRep)
{
    for (NSInteger y=0; y<imageRep.pixelsHigh; y++) {
        for (NSInteger x=0; x<imageRep.pixelsWide; x++) {
            NSColor *color = [imageRep colorAtX:x y:y];
            if ([color alphaComponent] >= BBKAlphaLimit) return (imageRep.pixelsHigh - y);
        }
    }
    return 0;
}

// 下側の境界座標を返す
NSInteger trimBottom(NSBitmapImageRep *imageRep)
{
    for (NSInteger y=imageRep.pixelsHigh; y>=0; y--) {
        for (NSInteger x=0; x<imageRep.pixelsWide; x++) {
            NSColor *color = [imageRep colorAtX:x y:y];
            if ([color alphaComponent] >= BBKAlphaLimit) return (imageRep.pixelsHigh - y - 1);
        }
    }
    return 0;
}

// 指定した透明度以上の領域を含む最小のrectを返す
NSRect trimRectFromImageByAlphaValue(NSImage *image)
{
    NSBitmapImageRep* imageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation] ];
    CGFloat scale = displayScale();
    
    NSRect trimRect = NSZeroRect;
    trimRect.origin.x = (float)trimLeft(imageRep)/scale;
    trimRect.origin.y = (float)trimBottom(imageRep)/scale;
    trimRect.size.width = (float)trimRight(imageRep)/scale - trimRect.origin.x;
    trimRect.size.height = (float)trimTop(imageRep)/scale - trimRect.origin.y;
    
//    NSLog(@"%f, %f, %f, %f", trimRect.origin.x, trimRect.origin.y, trimRect.size.width, trimRect.size.height);
    return trimRect;
}

// 指定した範囲に画像を切り取って返す
NSImage* trimImageByRect(NSImage *image, NSRect trimRect)
{
    CGFloat scale = displayScale();
    //Retina環境に応じたポイントサイズを取得する
    NSBitmapImageRep* imageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation] ];
    NSSize pointSize = NSMakeSize(imageRep.pixelsWide/scale, imageRep.pixelsHigh/scale);
    //解像度を統一する（画像によって72dpiと144dpiの2つの設定があるので）
    [image setSize:pointSize];
    //描画する場所を準備
    NSRect newRect = NSZeroRect;
    newRect.size = trimRect.size;
    NSImage *newImage = [ [NSImage alloc] initWithSize:newRect.size];
    //描画する場所=newImageに狙いを定める、描画環境を保存しておく
    [newImage lockFocus];
    [NSGraphicsContext saveGraphicsState];
    //拡大・縮小した時の補間品質の指定
    [ [NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    //描画する
    [image drawAtPoint:NSZeroPoint fromRect:trimRect operation:NSCompositeSourceOver fraction:1.0];
    //描画環境を元に戻す、描画する場所=newImageから狙いを外す
    [NSGraphicsContext restoreGraphicsState];
    [newImage unlockFocus];
    
    return newImage;
}

// 影付きイメージを描画して返す
NSImage* dropshadowImage(NSImage *image, float blurRadius, float alphaValue, bool outline)
{
    float margin = blurRadius;
    CGFloat scale = displayScale();
    //Retina環境に応じたポイントサイズを取得する
    NSBitmapImageRep* imageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    NSSize dotSize = NSMakeSize(imageRep.pixelsWide/scale, imageRep.pixelsHigh/scale);
    //描画する場所を準備
    NSRect newRect = NSZeroRect;
    newRect.size.width = dotSize.width + margin*2;
    newRect.size.height = dotSize.height + margin*2;
    NSImage *newImage = [[NSImage alloc] initWithSize:newRect.size];
    //描画する場所=newImageに狙いを定める、描画環境を保存しておく
    [newImage lockFocus];
    [NSGraphicsContext saveGraphicsState];
    //拡大・縮小した時の補間品質の指定
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    NSRect drawRect;
    if (outline) {
        //影の設定（輪郭線のため）
        [shadow setShadowOffset:NSZeroSize];
        [shadow setShadowBlurRadius:1.0];
        [shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:alphaValue]];
        [shadow set];
        //描画する（輪郭線のため）
        drawRect.origin = NSMakePoint(margin, margin*1.25);
        drawRect.size = dotSize;
        //[image drawAtPoint:drawRect.origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        //drawAtPointでは、画像によっては解像度に2倍の差が出てしまうため、drawInRectで描画した
        [image drawInRect:drawRect
                 fromRect:NSZeroRect
                operation:NSCompositeSourceOver
                 fraction:1.0
           respectFlipped:YES
                    hints:nil];
    }
    //影の設定
    [shadow setShadowOffset:NSMakeSize(0.0, -blurRadius * 0.25)];
    [shadow setShadowBlurRadius:blurRadius];
    [shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:alphaValue]];
    [shadow set];
    //描画する
    drawRect.origin = NSMakePoint(margin, margin*1.25);
    drawRect.size = dotSize;
    //[image drawAtPoint:drawRect.origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    //drawAtPointでは、画像によっては解像度に2倍の差が出てしまうため、drawInRectで描画した
    [image drawInRect:drawRect
             fromRect:NSZeroRect
            operation:NSCompositeSourceOver
             fraction:1.0
       respectFlipped:YES
                hints:nil];
    
    //描画環境を元に戻す、描画する場所=newImageから狙いを外す
    [NSGraphicsContext restoreGraphicsState];
    [newImage unlockFocus];
    
    return newImage;
}

// PNGファイルとして保存する
void saveImageByPNG(NSImage *image, NSString* fileName)
{
    NSData *data = [image TIFFRepresentation];
    NSBitmapImageRep* bitmapImageRep = [NSBitmapImageRep imageRepWithData:data];
    NSDictionary* properties = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                           forKey:NSImageInterlaced];
    data = [bitmapImageRep representationUsingType:NSPNGFileType properties:properties];
    [data writeToFile:fileName atomically:YES];
}

void showUsage()
{
    printf("\n");
    printf("Usage: shadow [-a ALPAH_VALUE(0-1)] [-b BLUR_RADIUS(0<=)] [-owh] [FILE ...]\n");
    printf("  -o  Without outline.\n");
    printf("  -w  Rewrite original file.\n");
    printf("  -h  Help.\n");
    printf("\n");
    printf("Example:\n");
    printf("  shadow test.png             ->  Default shadow(= shadow -a0.5 -b8 test.png)\n");
    printf("  shadow -b4 test.png         ->  Nano shadow\n");
    printf("  shadow -b2 test.png         ->  Line shadow\n");
    printf("  shadow -b0 -a0 test.png     ->  None shadow\n");
    printf("  shadow -b56 -a0.8 test.png  ->  OS X shadow\n");
}




int main(int argc, char * argv[])
{
    
    @autoreleasepool {
        int opt, i;
        float blurRadius = 8.0; // -b
        float alphaValue = 0.5; // -a
        bool outline = YES;     // -o
        bool rewrite = NO;      // -w
        NSString *optText = @"";
        
        //opterr = 0;/* エラーメッセージを非表示にする */
        
        while((opt = getopt(argc, argv, "a:b:owh")) != -1){
            optText = [optText stringByAppendingString:[NSString stringWithFormat:@"-%c%s", opt, optarg ? optarg : ""]];
            switch(opt){
                case 'a':
                    sscanf(optarg, "%f", &alphaValue);
                    break;
                case 'b':
                    sscanf(optarg, "%f", &blurRadius);
                    break;
                case 'o':
                    outline = NO;
                    break;
                case 'w':
                    rewrite = YES;
                    break;
                case 'h':
                    showUsage();
                    return 0;
                
                // 解析できないオプションが見つかった場合は「?」を返す
                // オプション引数が不足している場合も「?」を返す
                case '?':
                    showUsage();
                    return 1;
            }
        }
        
        for(i = optind; i < argc; i++){
            // ファイルパスをパースしておく
//            NSString *aPath = @"~/a/b/c.d.e";
            NSString *aPath = [NSString stringWithUTF8String:argv[i]];
            NSString *fPath = [aPath stringByStandardizingPath];        // /Users/HOME/a/b/c.d.e
//          NSString *fDir = [fPath stringByDeletingLastPathComponent]; // /Users/HOME/a/b
//          NSString *fNameExt = [fPath lastPathComponent];             // c.d.e
            NSString *fExt = [fPath pathExtension];                     // e
            NSString *fDirName = [fPath stringByDeletingPathExtension]; // /Users/HOME/a/b/c.d
//            NSLog(@"name.ext=%@  ext=%@  dir=%@  dir/name=%@", fNameExt, fExt, fDir, fDirName);
            NSString *outputPath;
            if (rewrite) {
                outputPath = fPath;
            }else{
                outputPath = [NSString stringWithFormat:@"%@-shadow%@.%@", fDirName, optText, fExt];
            }
            
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:fPath];
            NSRect imageRect = NSMakeRect(0, 0, image.size.width, image.size.height);
            NSRect trimRect = trimRectFromImageByAlphaValue(image);
            if (!NSEqualRects(trimRect, imageRect)) {
                // 影の領域を削除した画像にする
                image = trimImageByRect(image, trimRect);
                // 影の部分を透明にする
                image = transparentImageByAlphaValue(image);
            }
            // 影付きイメージを生成する
            image = dropshadowImage(image, blurRadius, alphaValue, outline);
            // PNG画像として保存する
            saveImageByPNG(image, outputPath);
            // 画像情報を出力する
            NSLog(@"%@ %@", outputPath, NSStringFromRect(imageRect));
        }        
    }
    return 0;
}
