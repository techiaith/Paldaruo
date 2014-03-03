#pragma mark URL Consts

#ifdef DEBUG
    // Debug Build Config
    // #define kServerHost @"http://0.0.0.0:8082"
    #define kServerHost @"http://paldaruo.techiaith.bangor.ac.uk"
#else
    // Release Build
    #define kServerHost @"http://paldaruo.techiaith.bangor.ac.uk"
#endif

// Macro er mwyn creu URL i'r gweinydd
#define UTIServerURL(path) [kServerHost stringByAppendingPathComponent:path]