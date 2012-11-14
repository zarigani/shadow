//
//  main.m
//  shadow
//
//  Created by zarigani on 2012/11/15.
//  Copyright (c) 2012年 bebe工房. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// 影付きイメージを描画して返す
NSImage* dropshadowImage(NSImage *image, float blurRadius, float alphaValue)
{
    float margin = blurRadius * 1.25;
    //スケールを取得する
    CGFloat scale = [[NSScreen mainScreen] backingScaleFactor];
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
    //影の設定
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowOffset:NSMakeSize(0.0, -blurRadius * 0.25)];
    [shadow setShadowBlurRadius:blurRadius];
    [shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:alphaValue]];
    [shadow set];
    //描画する
    NSRect drawRect;
    drawRect.origin = NSMakePoint(margin, margin);
    drawRect.size = dotSize;
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




int main(int argc, char * argv[])
{
    
    @autoreleasepool {
        int opt, i;
        float blurRadius = 8.0;
        float alphaValue = 0.5;
        
        //opterr = 0;/* エラーメッセージを非表示にする */
        
        while((opt = getopt(argc, argv, "a:b:")) != -1){
            switch(opt){
                case 'a':
                    sscanf(optarg, "%f", &alphaValue);
                    printf("  Option -%c = %f\n", opt, alphaValue);
                    break;
                    
                case 'b':
                    sscanf(optarg, "%f", &blurRadius);
                    printf("  Option -%c = %f\n", opt, blurRadius);
                    break;
                    
                    // 解析できないオプションが見つかった場合は「?」を返す
                    // オプション引数が不足している場合も「?」を返す
                case '?':
                    printf("Unknown or required argument option -%c\n", optopt);
                    printf("Usage: dropshadow [-a ALPAH_VALUE(0-1)] [-b BLUR_RADIUS(0<)] FILE ...\n");
                    printf("Example:\n");
                    printf("    dropshadow test.png       ->  Default shadow(= dropshadow -a 0.5 -b 8 test.png)\n");
                    printf("    dropshadow -b 2 test.png  ->  Outline only\n");
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
            NSString *shadowPath = [[fDirName stringByAppendingString:@"-shadow."] stringByAppendingString:fExt];
            
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:fPath];
            
            // 影付きイメージを生成する
            NSImage *shadowImage = dropshadowImage(image, blurRadius, alphaValue);
            // PNG画像として保存する
            saveImageByPNG(shadowImage, shadowPath);
            // 画像情報を出力する
            NSRect align = [shadowImage alignmentRect];
            NSLog(@"%@ (%f, %f, %f, %f)", shadowPath, align.origin.x, align.origin.y, align.size.width, align.size.height);
        }        
    }
    return 0;
}
