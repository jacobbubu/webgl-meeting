# WebGL Part1

## How to run the demo

```
npm install
```

将安装 [`beefy`](https://github.com/chrisdickinson/beefy) 和其所依赖的其他 Package（Browserify, Coffee-Script, Watchif...），以及用于进行 Canvas 会话和动作控制的 [`canvas-testbed`](https://github.com/mattdesl/canvas-testbed) 和 [`toggle-button`](https://github.com/jacobbubu/toggle-button)。

读者如果不熟悉这种 Web Demo 方式，有时间可以了解一下。
这种基于 [`browserify`](https://github.com/substack/node-browserify) 的前端开发方式很适合 Demo 和原型的开发。

```
npm test -- ex01/ex01.coffee
```

然后打开浏览器，访问 `http://localhost:9966` 即可看到运行结果。

如果想运行不同的例子，只要修改后面文件路径即可，例如 `npm test -- ex02/ex02.coffee`

## Slides

在 ./slides-part1.key 中