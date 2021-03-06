SDWebImage内部实现过程
1.入口 setImageWithURL:placeholderImage:options: 会先把 placeholderImage 显示，然后 SDWebImageManager 根据 URL 开始处理图片。
2.进入 SDWebImageManager-downloadWithURL:delegate:options:userInfo:，交给 SDImageCache 从缓存查找图片是否已经下载 queryDiskCacheForKey:delegate:userInfo:。
3.先从内存图片缓存查找是否有图片，如果内存中已经有图片缓存，SDImageCacheDelegate 回调 imageCache:didFindImage:forKey:userInfo: 到 SDWebImageManager。
4.SDWebImageManagerDelegate 回调 webImageManager:didFinishWithImage: 到 UIImageView+WebCache 等前端展示图片。
5.如果内存缓存中没有，生成 NSInvocationOperation 添加到队列开始从硬盘查找图片是否已经缓存。
6.根据 URLKey 在硬盘缓存目录下尝试读取图片文件。这一步是在 NSOperation 进行的操作，所以回主线程进行结果回调 notifyDelegate:。
7.如果上一操作从硬盘读取到了图片，将图片添加到内存缓存中（如果空闲内存过小，会先清空内存缓存）。SDImageCacheDelegate 回调 imageCache:didFindImage:forKey:userInfo:。进而回调展示图片。
8.如果从硬盘缓存目录读取不到图片，说明所有缓存都不存在该图片，需要下载图片，回调 imageCache:didNotFindImageForKey:userInfo:。
9.共享或重新生成一个下载器 SDWebImageDownloader 开始下载图片。
10.图片下载由 NSURLConnection 来做，实现相关 delegate 来判断图片下载中、下载完成和下载失败。
11.connection:didReceiveData: 中利用 ImageIO 做了按图片下载进度加载效果。
12.connectionDidFinishLoading: 数据下载完成后交给 SDWebImageDecoder 做图片解码处理。
13.图片解码处理在一个 NSOperationQueue 完成，不会拖慢主线程 UI。如果有需要对下载的图片进行二次处理，最好也在这里完成，效率会好很多。
14.在主线程 notifyDelegateOnMainThreadWithInfo: 宣告解码完成，imageDecoder:didFinishDecodingImage:userInfo: 回调给 SDWebImageDownloader。
15.imageDownloader:didFinishWithImage: 回调给 SDWebImageManager 告知图片下载完成。
16.通知所有的 downloadDelegates 下载完成，回调给需要的地方展示图片。
17.将图片保存到 SDImageCache 中，内存缓存和硬盘缓存同时保存。写文件到硬盘也在以单独 NSInvocationOperation 完成，避免拖慢主线程。
18.SDImageCache 在初始化的时候会注册一些消息通知，在内存警告或退到后台的时候清理内存图片缓存，应用结束的时候清理过期图片。
19.SDWI 也提供了 UIButton+WebCache 和 MKAnnotationView+WebCache，方便使用。
20.SDWebImagePrefetcher 可以预先下载图片，方便后续使用。


SDWebImage options所有选项：
SDWebImageRetryFailed = 1 << 0,//失败后重试
SDWebImageLowPriority = 1 << 1,//UI交互期间开始下载，导致延迟下载比如UIScrollView减速。
SDWebImageCacheMemoryOnly = 1 << 2,//只进行内存缓存
SDWebImageProgressiveDownload = 1 << 3,//这个标志可以渐进式下载,显示的图像是逐步在下载
SDWebImageRefreshCached = 1 << 4,//刷新缓存
SDWebImageContinueInBackground = 1 << 5,//后台下载
SDWebImageHandleCookies = 1 << 6,//NSMutableURLRequest.HTTPShouldHandleCookies = YES;
//SDWebImageAllowInvalidSSLCertificates = 1 << 7,//允许使用无效的SSL证书
SDWebImageHighPriority = 1 << 8,//优先下载
SDWebImageDelayPlaceholder = 1 << 9,//延迟占位符
SDWebImageTransformAnimatedImage = 1 << 10,//改变动画形象


tableView图片优化思路
1.当用户手动drag tableview的时候会加载cell中的图片
2.在用户快速滑动的减速过程中不加载过程中cell的图片（但文字信息还是会被加载，只是减少减速过程中的网络开销和图片加载的开销）
    2.1如果内存中有图片的缓存，减速过程中也加载该图片
    2.2如果图片属于targetContentOffSet能看到的cell正常加载，这样一来快速滚动的最后一屏出来的过程总用户就能看到目标区域的图片逐渐加载
    2.3尝试用类似fade in或者flip的效果缓解生硬的突然出现
3.在减速结束后加载所有可见cell中的图片（如果需要的话）