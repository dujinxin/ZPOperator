# ZPOperator
正品溯源-操作员APP

1.采用纯swift语言 + storyboard 开发，
2.集成afnetworking,sdwebimage,mjrefresh,MBProgressHUD,TZImagePickerController,Qiniu
3.采用mvvm设计模式
3. 1>基于af封装了网路请求（URL构建，request构建，request缓存，数据解析，公共错误处理，回调，token失效处理）
   2>采用系统定位，实现了定位，逆地理编码等
   3>封装七牛云图片上传（单图，多图）
   4>封装了各种弹出视图（包括选择视图、列表，toast），分页滑动视图
   5>实现了各种extension（可以直接快速使用的计算型属性，抽取公共可复用方法）
4.学习练习了swift语法以及storyboard在项目中的实际应用
   1>以前用的很少的storyboard，不同viewController之间的跳转（1.连线show,push,model等，2.代码控制通过performSegue，3.perfor传值通过prepare方法，记着要有identifier）
   2>大量使用了静态表格（静态表格有关section的设置，storyboard提供的太有限，需要通过代理来设置，cell的高度也可以通过代理来做，但是cell,number不可通过代理来做）
   3>大量大练习可选项，guard let,if let 语法，简单enum的使用,闭包，计算型属性，set,get方法的使用，协议的简单使用，extension的使用，已经遍历构造函数，重写，for语法，switch语法，断言，文件，string，array，dictionary......
