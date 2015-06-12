JAVA程序猿一枚,开始学习Swift一个多月,以前没有iOS的经验.在看了官方的文档和老镇的豆瓣电台视频后,想自己做一个东西来练手,因此有了这个东西.
  
在做的过程中,遇到了很多的问题,没想到一个看似很简单的东西,真要给它做像了,还是比较麻烦的,要学习的东西很多. 我现在只能尽量的把样子做像了,代码这些一团糟,很多思维都还是JAVA的思维,以后接触多了后,再来重构吧.  

因为我没有入手开发者账号,因此我只在模拟器中运行了,并且是 iOS8和iphone6的模式下测试.估计选择其他的是有问题的.不过,貌似Xcode7支持非开发者真机调试了,这真是令开发大快人心的大好事.到时候我再来尝试兼容ipad,估计要改很多的地方.
    

#Screenshot
![alt text](http://git.oschina.net/xycm/ZhiHuDaily-Swift/raw/master/screenshot.gif "程序运行截图 2015-06-12 09:51:26")

#API 说明
* API这里要感谢[@izzyleung](https://github.com/izzyleung/ZhihuDailyPurify/wiki/%E7%9F%A5%E4%B9%8E%E6%97%A5%E6%8A%A5-API-%E5%88%86%E6%9E%90 "感谢")   , 给予了很大的帮助,基本上就是把他的分析稍微有些修改.感谢[@izzyleung](https://github.com/izzyleung/ZhihuDailyPurify/wiki/%E7%9F%A5%E4%B9%8E%E6%97%A5%E6%8A%A5-API-%E5%88%86%E6%9E%90 "感谢")! [@izzyleung](https://github.com/izzyleung/ZhihuDailyPurify/wiki/%E7%9F%A5%E4%B9%8E%E6%97%A5%E6%8A%A5-API-%E5%88%86%E6%9E%90 "感谢")! [@izzyleung](https://github.com/izzyleung/ZhihuDailyPurify/wiki/%E7%9F%A5%E4%B9%8E%E6%97%A5%E6%8A%A5-API-%E5%88%86%E6%9E%90 "感谢")!重要的事情要说三遍.
* 知乎日报的消息以 JSON 格式输出
* 网址中 `api` 后数字代表 API 版本，过高或过低均会得到错误信息
* 较老的接口（启动界面图像获取，最新消息，过往消息）中将数字 2 替换为 1.2 获得效果相同，替换为 1.1 获得的是老版本 API 输出的 JSON 格式（替换为更低，如 1.0，或更高，如 1.3，将会获得错误消息）
* 以下所有 API 使用的 HTTP Method 均为 `GET`

#API 分析
--
###1. 启动界面图像获取
* URL: `http://news-at.zhihu.com/api/4/start-image/{aspec}`
* `start-image` 后为图像分辨率，接受如下格式
	* 320*432
	* 480*728
	* 720*1184
	* 1080*1776
* 响应实例:

```json
{
	text: "© Fido Dido",
	img: "http://p2.zhimg.com/10/7b/107bb4894b46d75a892da6fa80ef504a.jpg"
	} 
``` 
* 分析:  

|字段名|备注|
|---|---|
| text |供显示的图片版权信息|
|img|图像的URL地址|

###2. 软件版本查询
* Android:`http://news-at.zhihu.com/api/4/version/android/2.3.0`
* IOS:`http://news-at.zhihu.com/api/4/version/ios/{version}`
* URL 最后部分的数字代表所安装『知乎日报』的版本
* 响应实例：
	* 软件为最新版本时:
	
	```json
	{
	"status": 0,
	"latest": "2.2.0"
	}
	```
	
	* 软件为较老版本时:
	
	```json
	{
	"status": 1,
	"msg": "【更新内容】（后略）",
	"latest": "2.2.0"
	}
	```
* 分析:

|字段名|备注|
|---|---|
| status |0 代表软件为最新版本，1 代表软件需要升级|
| latest |软件最新版本的版本号（数字的第二段会比最新的版本号低 1）|
| msg |仅出现在软件需要升级的情形下，提示用户升级软件的对话框中显示的消息|

###3. 最新消息
* URL:`http://news-at.zhihu.com/api/4/news/latest`
* 响应实例:

```json
{
	date: "20140523",
	stories: [
	{
	title: "中国古代家具发展到今天有两个高峰，一个两宋一个明末（多图）",
	ga_prefix: "052321",
	images: [
	"http://p1.zhimg.com/45/b9/45b9f057fc1957ed2c946814342c0f02.jpg"
	 ],
	type: 0,
	id: 3930445
	},
	...
	],
	top_stories: [
	{
	title: "商场和很多人家里，竹制家具越来越多（多图）",
	image: "http://p2.zhimg.com/9a/15/9a1570bb9e5fa53ae9fb9269a56ee019.jpg",
	ga_prefix: "052315",
	type: 0,
	id: 3930883
	},
	...
	]
	}
```
* 分析

|字段名|备注|
|---|---|
| date |日期|
| stories |当日新闻|
| -> title |新闻标题|
| -> images |图像地址（官方 API 使用数组形式。目前暂未有使用多张图片的情形出现，曾见无 `images` 属性的情况，请在使用中注意 ）|
| -> ga_prefix |供 Google Analytics 使用|
| -> type | 作用未知|
| -> id | url 与 share_url 中最后的数字（应为内容的 id）|
| -> multipic | 消息是否包含多张图片（仅出现在包含多图的新闻中）|
| top_stories | 界面顶部 ViewPager 滚动显示的显示内容（子项格式同上）|

###4. 消息内容获取与离线下载
* URL:`http://news-at.zhihu.com/api/4/news/{id}`
* 响应实例:

```json
{
    body: "<div class=\"main-wrap content-wrap\">\n<div class=\"headline\">\n\n<div class=\"img-place-holder\"></div>\n\n\n\n</div>\n\n<div class=\"content-inner\">\n\n\n\n\n<div class=\"question\"> ... </div>",
    image_source: "Yestone.com 版权图片库",
    title: "瞎扯 · 如何正确地吐槽",
    image: "http://pic2.zhimg.com/9fe062c07b11959a2dd47068e116a9d5.jpg",
    share_url: "http://daily.zhihu.com/story/4760976",
    js: [],
    recommenders: [
        {
            avatar: "http://pic3.zhimg.com/449b2931521389e4fcbc31a0e2d9d896_m.jpg"
        },
        {
            avatar: "http://pic1.zhimg.com/4e45f545ee8b194476d3131ca7f3a9c8_m.jpg"
        },
        {
            avatar: "http://pic4.zhimg.com/6a682ab23_m.jpg"
        }
    ],
    ga_prefix: "052606",
    section: {
        thumbnail: "http://pic3.zhimg.com/a82322fc78dff305c3df43fcc4cb96c2.jpg",
        id: 2,
        name: "瞎扯"
    },
    type: 0,
    id: 4760976,
    css: [
        "http://news.at.zhihu.com/css/news_qa.auto.css?v=1edab"
    ]
}
```
*分析:

|字段名|备注|
|---|---|
| body |`HTML`格式的新闻内容|
| image-source |图片的内容提供方。为了避免被起诉非法使用图片，在显示图片时最好附上其版权信息。|
| title |新闻标题|
| image |获得的图片同 `最新消息` 获得的图片分辨率不同。这里获得的是在文章浏览界面中使用的大图。|
| share_url |供在线查看内容与分享至 SNS 用的 URL|
| js | 供手机端的 WebView(UIWebView) 使用|
| recommenders | 推荐者 |
| -> avatar | 推荐者的头像 |
| ga_prefix | 供 Google Analytics 使用|
| section | 栏目 |
| -> thumbnail | 缩略图 |
| -> id | 栏目id|
| -> name | 栏目名称 |
| type | 新闻的类型|
| id | 新闻的 id|
| css | 供手机端的 WebView(UIWebView) 使用|

**可知，知乎日报的文章浏览界面利用 WebView(UIWebView) 实现**

* **特别注意**  
在较为特殊的情况下，知乎日报可能将某个主题日报的站外文章推送至知乎日报首页。

	* 响应实例:
	
	```json
	{
"theme_name": "电影日报",
"title": "五分钟读懂明星的花样昵称：一美、法鲨……",
"share_url": "http://daily.zhihu.com/story/3942319",
"js": [],
"ga_prefix": "052921",
"editor_name": "邹波",
"theme_id": 3,
"type": 1,
"id": 3942319,
"css": [
"http://news.at.zhihu.com/css/news_qa.6.css?v=b390f"
]
}
	```
	
	此时返回的 JSON 数据缺少 `body`，`iamge-source`，`image`，`js` 属性。多出 `theme_name`，`editor_name`，`theme_id` 三个属性。`type` 由 0 变为 1。

###4.5 新闻推荐者信息
* URL:`http://news-at.zhihu.com/api/4/story/#{id}/recommenders`
* 这个返回的就是某一篇新闻的推荐者的详细信息.
* 响应实例:

```json
{
    "items": [
        {
            "index": 1,
            "recommenders": [
                {
                    "bio": "",
                    "zhihu_url_token": "90b373201c03b47548dcac5832da1a95",
                    "id": 1162,
                    "avatar": "http://pic1.zhimg.com/f81b942d0_m.jpg",
                    "name": "Wang Chris"
                },
                {
                    "bio": "Phys2CS",
                    "zhihu_url_token": "d2facf05b7138a6eb4631a161915f7d4",
                    "id": 629,
                    "avatar": "http://pic3.zhimg.com/9dfd356e2f137540439448fa25ef0ea6_m.jpg",
                    "name": "Badger"
                },
                {
                    "bio": "",
                    "zhihu_url_token": "75a591efecfd4c22a6fc778a38a90f8d",
                    "id": 69,
                    "avatar": "http://pic1.zhimg.com/428ce35d11440c08c83f46dbfe435a5c_m.jpg",
                    "name": "One Two"
                },
                {
                    "bio": "重新做人",
                    "zhihu_url_token": "4d2540e03e0e5e225f4817f7ff7fc389",
                    "id": 7895,
                    "avatar": "http://pic3.zhimg.com/816934c948f5e3cc781ecda1ece08c3e_m.jpg",
                    "name": "王RRR"
                },
                {
                    "bio": "金融菜鸟 音乐草根 技能点加歪",
                    "zhihu_url_token": "b929aa5072baae224a74a18b5bd65376",
                    "id": 2576,
                    "avatar": "http://pic4.zhimg.com/1814a1b987a44cc49a448268412dbe23_m.jpg",
                    "name": "酷冰"
                },
                {
                    "bio": "你读书少，不骗你骗谁。",
                    "zhihu_url_token": "1cd7424d0a7990aaff8e2ed24644992a",
                    "id": 369,
                    "avatar": "http://pic3.zhimg.com/bbb689a7a_m.jpg",
                    "name": "卞卡"
                },
                {
                    "bio": "智商捉不了鸡",
                    "zhihu_url_token": "794c4d35096ad3dafb802124cdd83294",
                    "id": 5778,
                    "avatar": "http://pic4.zhimg.com/131bb14f5a12920afc975b3833538027_m.jpg",
                    "name": "二核桃"
                },
                {
                    "bio": "软件工程师",
                    "zhihu_url_token": "93ce68e327ef290f84192014bbc168b2",
                    "id": 6519,
                    "avatar": "http://pic2.zhimg.com/5d55b2e8d_m.jpg",
                    "name": "戴威"
                }
            ],
            "author": {
                "name": "灿妞儿"
            }
        },
        {
            "index": 2,
            "recommenders": [
                {
                    "bio": "",
                    "zhihu_url_token": "75a591efecfd4c22a6fc778a38a90f8d",
                    "id": 69,
                    "avatar": "http://pic1.zhimg.com/428ce35d11440c08c83f46dbfe435a5c_m.jpg",
                    "name": "One Two"
                }
            ],
            "author": {
                "name": "Badger"
            }
        }
    ],
    "item_count": 3
}
```

* 分析:

|字段名|备注|
|---|---|
| item_count |表示这篇日报里面有 几篇内容|
| items |表示推荐者信息|
| -->index |表示这个推荐信息对应的是日报中的第几篇内容|
| -->recommenders |推荐者信息|
| ---->bio |推荐者的个性备注|
| ---->zhihu_url_token | 用户的token |
| ---->id | 用户id |
| ---->avatar | 用户头像|
| ---->name | 用户名 |
| --> author | 第几篇内容对应的作者 |
| ----> name | 第几篇内容对应的作者的名字|



###5. 过往消息
* URL:`http://news.at.zhihu.com/api/4/news/before/{date}`
* 若果需要查询 11 月 18 日的消息，{date}的数字应为 20131119
* 知乎日报的生日为 2013 年 5 月 19 日，若 {date}数字小于 20130520 ，只会接收到空消息
* 响应实例：

```json
{
	date: "20131118",
	stories: [
	    {
	        title: "深夜食堂 · 我的张曼妮",
	        ga_prefix: "111822",
	        images: [
	            "http://p4.zhimg.com/7b/c8/7bc8ef5947b069513c51e4b9521b5c82.jpg"
	        ],
	        type: 0,
	        id: 1747159
	    },
	...
	]
}

```
格式与前同，恕不再赘述

###6. 新闻额外信息
* URL: `http://news-at.zhihu.com/api/4/story-extra/#{id}`
* 输入新闻的ID，获取对应新闻的额外信息，如评论数量，所获的『赞』的数量。
* 响应实例：

```json
{
"long_comments": 0,
"popularity": 161,
"short_comments": 19,
"comments": 19,
}
```
* 分析:

|字段名|备注|
|---|---|
| long_comments  |长评论总数|
| popularity |点赞总数|
| short_comments| 短评论总数|
| comments | 评论总数 |

###7. 新闻对应长评论查看
* URL: http://news-at.zhihu.com/api/4/story/#{id}/long-comments
* 使用在 `最新消息` 中获得的 `id`，传入#{id}，得到长评论 JSON 格式的内容
* 响应实例:

```json
{
	"comments": [
	    {
	        "author": "EleganceWorld",
	        "id": 545442,
	        "content": "上海到济南，无尽的猪排盖饭… （后略）",
	        "likes": 0,
	        "time": 1413589303,
	        "avatar": "http://pic2.zhimg.com/1f76e6a25_im.jpg"
	    },
	    ...
	]
}
```
*分析:

|字段名|备注|
|---|---|
| comments  |长评论列表，形式为数组（请注意，其长度可能为 0）|
| author |评论作者|
| id | 评论者的唯一标识符|
| content | 评论的内容 |
| likes | 评论所获『赞』的数量 |
| time | 评论时间 |
| avatar | 用户头像图片的地址 |

###8. 新闻对应短评论查看
* URL: `http://news-at.zhihu.com/api/4/story/#{id}/short-comments`
* 使用在 `最新消息` 中获得的 `id`，传入#{id}，得到短评论 JSON 格式的内容
* 最新的测试结果,一次只返回20条.具体如何分页需要再分析
* 响应实例:

```json
{
	"comments": [
	    {
	        "author": "Xiaole说",
	        "id": 545721,
	        "content": "就吃了个花生米，呵呵",
	        "likes": 0,
	        "time": 1413600071,
	        "avatar": "http://pic1.zhimg.com/c41f035ab_im.jpg"
	    },
	    ...
	]
}
```
格式与前同，恕不再赘述

###9. 主题日报列表查看
* URL: http://news-at.zhihu.com/api/4/themes
* 响应实例：

```json  
{
    "limit": 1000,
    "subscribed": [],
    "others": [
        {
            "color": 15007,
            "thumbnail": "http://pic3.zhimg.com/0e71e90fd6be47630399d63c58beebfc.jpg",
            "description": "了解自己和别人，了解彼此的欲望和局限。",
            "id": 13,
            "name": "日常心理学"
        }
        ...
    ]
}
```

* 分析:

|字段名|备注|
|---|---|
| limit  |返回数目之限制（仅为猜测）|
| subscribed | 已订阅条目 |
| others | 其他条目|
| -> color | 颜色，作用未知 |
| -> thumbnail | 供显示的图片地址 |
| -> description | 主题日报的介绍 |
| -> id | 该主题日报的编号 |
| -> name | 供显示的主题日报名称 |

###10. 主题日报内容查看
* URL: http://news-at.zhihu.com/api/4/theme/#{id}
* 使用在 `主题日报列表查看` 中获得需要查看的主题日报的 id，赋值给#{id}，得到对应主题日报 JSON 格式的内容
* 响应实例：

```json
{
    "stories": [
        {
            "images": [
                "http://pic4.zhimg.com/fabeb6ece13d1b4f3fecd484f475feeb_t.jpg"
            ],
            "type": 2,
            "id": 4759968,
            "title": "你的密码保护问题真的安全吗？"
        },
        {
            "images": [
                "http://pic2.zhimg.com/969a13db3fad18b1d35ce9d3e2633ef1_t.jpg"
            ],
            "type": 2,
            "id": 4745004,
            "title": "当DNS泄漏让VPN不再安全，我们该怎么办？"
        },
 		...
    ],
    "description": "把黑客知识科普到你的面前",
    "background": "http://p4.zhimg.com/32/55/32557676e84fcfda4d82d9b8042464e1.jpg",
    "color": 9699556,
    "name": "互联网安全",
    "image": "http://p4.zhimg.com/30/6f/306f3ab291c415f40fe4485b75627230.jpg",
    "editors": [
        {
            "url": "http://www.zhihu.com/people/THANKS",
            "bio": "FreeBuf.com 小编，专注黑客与极客",
            "id": 65,
            "avatar": "http://pic4.zhimg.com/ecd93e213_m.jpg",
            "name": "THANKS"
        },
        {
            "url": "http://www.zhihu.com/people/____",
            "bio": "PKAV & Wooyun",
            "id": 38,
            "avatar": "http://pic1.zhimg.com/815b2ec82_m.jpg",
            "name": "长短短"
        },
        ...
    ],
    "image_source": ""
}
```

* 分析:

|字段名|备注|
|---|---|
| stories |该主题日报中的文章列表|
| -> images | 图像地址（其类型为数组。请留意在代码中处理无该属性与数组长度为 0 的情况）|
| -> type | 类型，作用未知 |
| -> title |消息的标题|
| -> id |消息的id|
| description | 该主题日报的介绍|
| background | 该主题日报的背景图片（大图） |
| color | 颜色，作用未知 |
| name | 该主题日报的名称 |
| image | 背景图片的小图版本 |
| editors | 该主题日报的编辑（『用户推荐日报』中此项的指是一个空数组，在 App 中的主编栏显示为『许多人』，点击后访问该主题日报的介绍页面，请留意) |
| -> url | 主编的知乎用户主页|
| -> bio | 主编的个人简介 |
| -> id | 数据库中的唯一表示符 |
| -> avatar | 主编的头像 |
| -> name | 主编的姓名 |
| image_source | 图像的版权信息|
