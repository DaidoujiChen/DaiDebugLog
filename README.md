DaiDebugLog
===========

開發者與工作夥伴的溝通利器!

![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/DaiDebugLog.gif)

DaidoujiChen

daidoujichen@gmail.com

總覽
===========
[FLEX](https://github.com/Flipboard/FLEX) 很強大, 但是過多的資訊只有 app 開發者知道其中的含意與使用規則, 所以我想建立一個工具, 可以幫助我們, 快速, 且明確的讓與我們合作的其他夥伴, 也可以輕鬆的得到他們想要的資訊, 

	* 從 Demo 的圖片中, 我大概記錄下幾件事情
		1. app 回報給 GA / Flurry 的訊息 for 分析專長
		2. 記錄 app request / responder 的內容 for 後端
		3. 點擊 view 時, 可以知道他的大小, 與邊界的距離 for UI / UX

簡易使用
===========
將包含 `Core` / `Utility` 的資料夾 `DaiDebugLog` copy 到你的專案中, 然後在 `application:didFinishLaunchingWithOptions:` 裡面調用 `[DaiDebugLog show];`, 就可以將主要功能顯示在畫面上, 前後加上 `#if DEBUG` 確保我們只在 `DEBUG` 時使用他

`````
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if DEBUG
	[DaiDebugLog show];
#endif
}
`````

添加 LOG
===========
非常的簡單, 就調用 `[DaiDebugLog addLog:];` 即可

`````
#if DEBUG
	[DaiDebugLog addLog:@"Hahaha"];
#endif
`````

Todo
===========
- 任意選擇兩個 view, 計算他們的間距與相關訊息
- 如果點擊的是 view 是有字型內容的, 顯示他所內含的資訊