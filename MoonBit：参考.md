# MoonBit：新手之旅

本指南面向初学者，且并不打算作为一个几分钟就能读完的小文章。本文旨在为那些对 MoonBit 的编程思路 （更加现代化，函数式的）不甚了解的用户提供一个简洁而不失易懂性的指南。

如果您想直接深入了解语言，请参阅 [总体介绍](https://docs.moonbitlang.cn/language/index.html)。

## 安装

**语言扩展**

目前，MoonBit 的开发支持是通过 VS Code 扩展实现的。请前往 [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=moonbit.moonbit-lang) 下载 MoonBit 语言支持。

**工具链**

> （推荐）如果您已安装了上面的扩展，运行操作菜单中的“Install moonbit toolchain” 即可直接安装运行时并跳过这部分介绍：![安装运行时](https://docs.moonbitlang.cn/_images/runtime-installation.png)

我们还提供了一个安装脚本：Linux 和 macOS 用户可以通过以下方式安装：

```
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash
```



对于 Windows 用户，使用 Powershell：

```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser; irm https://cli.moonbitlang.com/install/powershell.ps1 | iex
```



这将自动安装 MoonBit 到 `$HOME/.moon` 并将其添加到您的 `PATH`。

如果安装后遇到 `moon` 未找到的情况，请尝试重新启动终端或 VSCode 以使环境变量生效。

请注意，目前 MoonBit 还不适用于生产环境：它正在积极开发中。要更新 MoonBit，只需再次运行上面的命令即可。

运行 `moon help` 可以看到一堆子命令。但是现在我们只需要 `build` `run` 和 `new` 这三个命令。

要创建一个项目（或者说模块），运行 `moon new <path>`，其中 是您希望放置项目的位置。例如，如果您执行 `moon new examine`，您将得到：

```
examine
├── Agents.md
├── cmd
│   └── main
│       ├── main.mbt
│       └── moon.pkg
├── LICENSE
├── moon.mod
├── moon.pkg
├── examine_test.mbt
├── examine.mbt
├── README.mbt.md
└── README.md -> README.mbt.md
```



其中包含一个 `cmd/main` 包，内有一个 `fn main` 作为程序的入口。尝试运行 `moon run cmd/main`。

在这个教程中，我们假设项目名称为 `examine`，当前工作目录也是 `examine`。

## 示例：找到通过考试的人

在这个例子中，我们将尝试找出，给定一些学生的分数，有多少人通过了考试？

为此，我们将从定义数据类型开始，确定我们的函数，并编写我们的测试。然后我们将实现我们的函数。

除非另有说明，以下内容将在文件 `examine.mbt` 中定义。

### 数据类型

MoonBit 中的 [基本数据类型](https://docs.moonbitlang.cn/language/fundamentals.html#built-in-data-structures) 包括以下内容：

- `Unit`
- `Bool`
- `Int32`, `UInt32`, `Int64`, `UInt64`, `Byte`, ...
- `Float`, `Double`
- `Char`, `String`, ...
- `Array[T]`, ...
- 元组，和其他类型

要使用原始类型表示包含学生 ID 和分数的记录，我们可以使用一个包含学生 ID（类型为 `String`）和分数（类型为 `Double`）的 2-元组，如 `(String, Double)`。然而，这并不是很直观，因为我们无法区分其他可能的数据类型，例如包含学生 ID 和学生身高的记录。

因此，我们选择使用 [结构体](https://docs.moonbitlang.cn/language/fundamentals.html#struct) 声明我们自己的数据类型：

```
struct Student {
  id : String
  score : Double
}
```



一个人可以通过或者不通过考试，因此判断结果可以使用 [枚举类型](https://docs.moonbitlang.cn/language/fundamentals.html#enum) 定义：

```
enum ExamResult {
  Pass
  Fail
}
```



### 函数

[函数](https://docs.moonbitlang.cn/language/fundamentals.html#functions) 是一段代码，它接受一些输入并产生一个结果。

在我们的例子中，我们需要判断一个学生是否通过了考试：

```
fn is_qualified(student : Student, criteria: Double) -> ExamResult {
  ...
}
```



这个函数接受一个类型为 `Student` 的输入 `student`，一个类型为 `Double` 的输入 `criteria`（因为每门课程的标准可能不同，每个国家的标准可能不同）然后返回一个 `ExamResult`。

使用 `...` 语法可以让我们暂时不实现函数。

我们还需要找出有多少学生通过了考试：

```
fn count_qualified_students(
  students : Array[Student],
  is_qualified : (Student) -> ExamResult
) -> Int32 {
  ...
}
```



在 MoonBit 中，函数是一等公民，这意味着我们可以将一个函数绑定到一个变量，将一个函数作为参数传递或将一个函数作为结果接收。这个函数接受一个学生记录数组和另一个函数，判断学生是否通过了考试。

### 编写测试

我们可以定义内联测试来定义函数的预期行为。这也有助于确保在重构程序时不会出现回归（破坏现有行为）。

```
test "is qualified" {
  assert_eq(is_qualified(Student::{ id : "0", score : 50.0 }, 60.0), Fail)
  assert_eq(is_qualified(Student::{ id : "1", score : 60.0 }, 60.0), Pass)
  assert_eq(is_qualified(Student::{ id : "2", score : 13.0 }, 7.0), Pass)
}
```



我们会收到报错信息，提醒我们 `ExamResult` 没有实现 `Show` 和 `Eq`。

`Show` 和 `Eq` 是 **traits**。在 MoonBit 中，trait 定义了一个类型应该能够执行的一些常见操作。

例如，`Eq` 定义了应该有一种方法来比较两个相同类型的值，这个方法叫做 `op_equal`：

```
trait Eq {
  op_equal(Self, Self) -> Bool
}
```



`Show` 定义了应该有一种方法，要么将一个类型的值转换为 `String`，要么使用 `Logger` 写入：

```
trait Show {
  output(Self, &Logger) -> Unit
  to_string(Self) -> String
}
```



`assert_eq` 使用它们来约束传递的参数，以便比较两个值并在它们不相等时打印它们：

```
fn[A : Eq + Show] assert_eq!(value : A, other : A) -> Unit {
  ...
}
```



我们需要为我们的 `ExamResult` 实现 `Eq` 和 `Show`。有两种方法可以实现。

1. 通过定义一个显式实现：

   ```
   impl Eq for ExamResult with equal(self, other) {
     match (self, other) {
       (Pass, Pass) | (Fail, Fail) => true
       _ => false
     }
   }
   ```

   

   在这里，我们使用 [模式匹配](https://docs.moonbitlang.cn/language/fundamentals.html#pattern-matching) 来检查 `ExamResult` 的情况。

2. 另一种方法是通过 [派生](https://docs.moonbitlang.cn/language/derive.html) ，因为 `Eq` 和 `Show` 是 [内置 traits](https://docs.moonbitlang.cn/language/methods.html#builtin-traits) 并且 `ExamResult` 的输出非常直接：

   ```
   enum ExamResult {
     Pass
     Fail
   } derive(Show)
   ```

   

现在我们已经实现了 traits，我们可以继续实现我们的测试：

```
test "count qualified students" {
  let students = [
    { id: "0", score: 10.0 },
    { id: "1", score: 50.0 },
    { id: "2", score: 61.0 },
  ]
  let criteria1 = fn(student) { is_qualified(student, 10) }
  let criteria2 = fn(student) { is_qualified(student, 50) }
  assert_eq(count_qualified_students(students, criteria1), 3)
  assert_eq(count_qualified_students(students, criteria2), 2)
}
```



在这里，我们使用 [lambda 表达式](https://docs.moonbitlang.cn/language/fundamentals.html#local-functions) 来重用先前定义的 `is_qualified` 来创建不同的标准。

我们可以运行 `moon test` 来查看测试是否成功。

### 实现函数

对于 `is_qualified` 函数，只需要简单的比较：

```
fn is_qualified(student : Student, criteria : Double) -> ExamResult {
  if student.score >= criteria {
    Pass
  } else {
    Fail
  }
}
```



在 MoonBit 中，最后一个表达式的结果是函数的返回值，每个分支的结果是 `if` 表达式的值。

对于 `count_qualified_students` 函数，我们需要遍历数组，检查每个学生是否通过。

一个简单的版本是使用一个可变值和一个 [`for` 循环](https://docs.moonbitlang.cn/language/fundamentals.html#for-loop)：

```
fn count_qualified_students(
  students : Array[Student],
  is_qualified : (Student) -> ExamResult
) -> Int32 {
  let mut count = 0
  for i = 0; i < students.length(); i = i + 1 {
    if is_qualified(students[i]) == Pass {
      count += 1
    }
  }
  count
}
```



然而，这种方式既不高效（因为有边界检查）也不够直观，因此我们可以用 [`for .. in` 循环](https://docs.moonbitlang.cn/language/fundamentals.html#for-in-loop) 替换普通的 `for` 循环：

```
fn count_qualified_students(
  students : Array[Student],
  is_qualified : (Student) -> ExamResult
) -> Int32 {
  let mut count = 0
  for student in students {
    if is_qualified(student) == Pass { count += 1}
  }
  count
}
```



另一种方法是使用为 [迭代器](https://docs.moonbitlang.cn/language/fundamentals.html#iterator) 定义的函数：

```
fn count_qualified_students(
  students : Array[Student],
  is_qualified : (Student) -> ExamResult
) -> Int32 {
  students.iter().filter(fn(student) { is_qualified(student) == Pass }).count()
}
```



现在之前定义的测试应该通过了。

## 公开库

恭喜您完成了第一个 MoonBit 库！

您现在可以与其他开发人员分享它，这样他们就不需要重复您所做的工作。

但在此之前，您还有一些其他事情要做。

### 调整可见性

为了看到其他人如何使用我们的程序，MoonBit 提供了一种称为 [“黑盒测试”](https://docs.moonbitlang.cn/language/tests.html#blackbox-tests-and-whitebox-tests) 的机制。

让我们将上面定义的 `test` 块移动到一个新文件 `top_test.mbt` 中。

糟糕！现在有错误抱怨：

- `is_qualified` 和 `count_qualified_students` 未绑定
- `Fail` 和 `Pass` 未定义
- `Student` 不是一个记录类型，字段 `id` 未找到，等等。

所有这些问题都来自于可见性问题。默认情况下，定义的函数对当前包（由当前文件夹绑定）之外的程序的其他部分不可见。默认情况下，类型被视为抽象类型，即我们只知道存在类型 `Student` 和类型 `ExamResult`。通过使用黑盒测试，您可以确保您希望其他人拥有的一切确实被赋予了预期的可见性。

为了让其他人使用这些函数，我们需要在 `fn` 前添加 `pub` 使函数公开。

为了让其他人构造类型和读取内容，我们需要在 `struct` 和 `enum` 前添加 `pub(all)` 使类型公开。

我们还需要稍微修改 `count qualified students` 的测试，添加类型注释：

```
test "count qualified students" {
  let students: Array[@examine.Student] = [
    { id: "0", score: 10.0 },
    { id: "1", score: 50.0 },
    { id: "2", score: 61.0 },
  ]
  let criteria1 = fn(student) { @examine.is_qualified(student, 10) }
  let criteria2 = fn(student) { @examine.is_qualified(student, 50) }
  assert_eq(@examine.count_qualified_students(students, criteria1), 3)
  assert_eq(@examine.count_qualified_students(students, criteria2), 2)
}
```



请注意，我们使用 `@examine` 访问类型和函数，这是您的包的名称。这是其他人使用您的包的方式，但您可以在黑盒测试中省略它们。

现在，编译应该可以正常工作，测试应该再次通过。

### 发布库

现在您已经准备好了，您可以将这个项目发布到 [mooncakes.io](https://mooncakes.io/)，MoonBit 的模块注册中心。您也可以在那里找到其他有趣的项目。

1. 执行 `moon login` 并按照说明使用现有的 GitHub 账户创建您的账户。
2. 将 `moon.mod` 中的项目名修改为 `<你的 GitHub 账户名>/<项目名>`。运行 `moon check`，查看 `moon.pkg` 中是否还有其他受影响的位置。
3. 执行 `moon publish`，您就完成了。您的项目将可供他人使用。

默认情况下，项目将在 [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0.html) 下共享，这是一种宽松的许可证，允许每个人使用。您还可以通过更改 `moon.mod` 中的 `license` 字段和 `LICENSE` 的内容，使用其他许可证，例如 [MulanPSL 2.0](https://license.coscl.org.cn/MulanPSL2)。

### 结束语

到目前为止，我们已经了解了 MoonBit 的基本特性和一些不那么简单的特性，然而 MoonBit 是一个功能丰富的、多范式的编程语言。访问 [语言导览](https://tour.moonbitlang.com/) 了解更多语法和基本类型的信息，以及其他文档，更好地掌握 MoonBit。



# 原生 CLI 快速开始

本快速开始展示了一个简单但规范的 MoonBit CLI 布局：

- 将参数解析和业务逻辑放在库包中
- 保持 `cmd/main` 简洁
- 使用 `moonbitlang/async` 处理原生 IO
- 在不接触网络的情况下测试纯逻辑部分

这个示例使用 `moonbitlang/async`，它目前对 native 后端支持最好。

## 创建项目

先从一个普通的 MoonBit 模块开始：

```
moon new download_cli
cd download_cli
moon add moonbitlang/async@0.20.2
```



`argparse` 已经属于标准库，因此这个快速开始只需要添加 `moonbitlang/async`。

在 `moon.mod` 中把首选目标设置为 native，这样 `moon run` 和 `moon build` 默认就会使用 `moonbitlang/async` 支持最好的后端：

```
name = "username/download_cli"
version = "0.1.0"
import {
  "moonbitlang/async@0.20.2",
}
preferred_target = "native"
```



最终目录结构如下：

```
download_cli
├── cmd
│   └── main
│       ├── main.mbt
│       └── moon.pkg
├── cli_test.mbt
├── config.mbt
├── download.mbt
├── moon.mod
└── moon.pkg
```



## 在库包中保留解析逻辑

根包定义 CLI 契约。它负责命令的形状，并把 argv 转成带类型的配置值：

```
pub struct Config {
  url : String
  output : String?
} derive(Eq)

///|
pub extend Config with Eq::{not_equal, equal}

///|
pub fn command() -> @argparse.Command {
  @argparse.Command(
    "moon-fetch",
    about="Download a URL to stdout or a file",
    options=[
      @argparse.OptionArg(
        "output",
        short='o',
        about="Write the response body to this file",
      ),
    ],
    positionals=[
      @argparse.PositionArg(
        "url",
        about="HTTP or HTTPS URL to download",
        num_args=@argparse.ValueRange::single(),
      ),
    ],
  )
}

///|
pub fn parse_config(argv : ArrayView[String]) -> Config raise {
  let matches = @argparse.parse(command(), argv~)
  let values : Map[String, Array[String]] = matches.values
  guard values is { "url": [url], "output"? : output_paths, .. } else {
    fail("missing url")
  }
  let output = match output_paths {
    Some([output, ..]) => Some(output)
    _ => None
  }
  { url, output }
}
```



包描述文件从 `moonbitlang/core` 导入 `argparse`，并导入实现中使用的异步库：

```
import {
  "moonbitlang/core/argparse",
  "moonbitlang/async/fs",
  "moonbitlang/async/http",
  "moonbitlang/async/stdio",
}

import {
  "moonbitlang/core/test",
} for "test"
```



## 把异步 IO 收拢到一个函数中

`run` 负责实际下载。传入 `-o` 时，它会把响应体写入文件；否则直接写到标准输出：

```
pub async fn run(config : Config) -> Unit {
  let (response, body) = @http.get_stream(config.url)
  defer body.close()

  guard response.code is (200..<300) else {
    fail("download failed: \{response.code} \{response.reason}")
  }

  match config.output {
    Some(path) => {
      let file = @fs.create(path, permission=0o644)
      defer file.close()
      file.write_reader(body)
      @stdio.stderr.write("saved \{config.url} to \{path}\n")
    }
    None => @stdio.stdout.write_reader(body)
  }
}
```



## 保持 `main` 精简

`cmd/main` 通常只负责接线：读取 argv、构造配置并调用库入口点。

```
import {
  "moonbit-community/cli-quickstart-doc" @app,
  "moonbitlang/core/env",
  "moonbitlang/async",
}

pkgtype(kind: "executable")
```



```
async fn main {
  let argv = @env.args()
  let config = @app.parse_config(argv[1:])
  @app.run(config)
}
```



## 运行命令

将响应体写到标准输出：

```
moon run cmd/main https://example.com/feed.xml
```



将其写入文件：

```
moon run cmd/main https://example.com/feed.xml -o feed.xml
```



构建原生二进制：

```
moon build --target native
```



## 测试纯逻辑部分

解析器和配置整理逻辑不执行 IO，因此仍然很容易测试：

```
///|
test "parse config for stdout" {
  let config = @cli-quickstart-doc.parse_config(["https://example.com/feed.xml"])
  assert_eq(config.url, "https://example.com/feed.xml")
  @test.assert_eq(config.output, None)
}

///|
test "parse config for file output" {
  let config = @cli-quickstart-doc.parse_config([
    "https://example.com/feed.xml", "-o", "feed.xml",
  ])
  assert_eq(config.url, "https://example.com/feed.xml")
  guard config.output is Some(path) else { fail("expected an output path") }
  assert_eq(path, "feed.xml")
}
```



用下面的命令运行测试：

```
moon test
```



当 CLI 继续增长时，仍然沿用同样的拆分方式：

- 在库包中解析并校验输入

- 把副作用集中在少量 async 函数中

- 让 `cmd/main` 专注于接线

  

# 在一个 MoonBit 项目中开发全栈应用

本教程展示如何在一个 MoonBit 模块中构建一个小型全栈应用。

你将实现一套共享校验规则，并在以下两处复用：

- `frontend/`：展示本地告警并调用后端
- `backend/`：再次校验并返回 JSON 响应

关键在于 `supported_targets`：

- `frontend/` 为 `js`
- `backend/` 为 `native`
- `shared/` 与目标平台无关

## 前置条件

- 已安装 MoonBit 工具链
- 已安装用于 API 测试的 `hurl`

## 步骤 1：创建模块

```
moon new fullstack_one_project
cd fullstack_one_project
moon add moonbitlang/async@0.22.4
moon add moonbit-community/rabbita@0.16.4
```



项目结构：

```
fullstack_one_project
├── Makefile
├── moon.mod
├── backend
│   ├── api.hurl
│   ├── index.html
│   ├── main.mbt
│   └── moon.pkg
├── frontend
│   ├── main.mbt
│   └── moon.pkg
└── shared
    ├── moon.pkg
    ├── shared_test.mbt
    └── task.mbt
```



模块配置：

```
name = "moonbit-community/fullstack-one-project-doc"
version = "0.1.0"

import {
  "moonbitlang/async@0.22.4",
  "moonbit-community/rabbita@0.16.4",
}

preferred_target = "native"
supported_targets = "+wasm+wasm-gc+js+native"
```



## 步骤 2：实现共享领域校验

在 `shared/` 中定义带 `derive(ToJson, FromJson)` 的请求/响应类型，以及一个基于 `suberror` 的校验器。前后端都导入这个包。

```
import {
  "moonbitlang/core/json",
}
```



```
pub(all) struct SubmitTitleRequest {
  title : String
} derive(Eq, ToJson, FromJson)

///|
pub extend SubmitTitleRequest with Eq::{not_equal, equal}

///|
pub extend SubmitTitleRequest with ToJson::{to_json}

///|
pub extend SubmitTitleRequest with @moonbitlang/core/json.FromJson::{from_json}

///|
pub(all) suberror TitleValidationError {
  EmptyTitle
  TooLong(Int32)
  ForbiddenHash
} derive(Eq, ToJson, FromJson)

///|
pub extend TitleValidationError with Eq::{not_equal, equal}

///|
pub extend TitleValidationError with ToJson::{to_json}

///|
pub extend TitleValidationError with @moonbitlang/core/json.FromJson::{from_json}

///|
pub(all) enum SubmitTitleResponse {
  Accepted(String)
  ValidationError(TitleValidationError)
  InvalidJson
} derive(Eq, ToJson, FromJson)

///|
pub extend SubmitTitleResponse with Eq::{not_equal, equal}

///|
pub extend SubmitTitleResponse with ToJson::{to_json}

///|
pub extend SubmitTitleResponse with @moonbitlang/core/json.FromJson::{from_json}

///|
pub fn validate_request(
  request : SubmitTitleRequest,
) -> Unit raise TitleValidationError {
  let title = request.title.trim().to_owned()
  if title.length() == 0 {
    raise EmptyTitle
  } else if title.length() > 24 {
    raise TooLong(title.length())
  } else if title.rev_find("#") is Some(_) {
    raise ForbiddenHash
  }
}

///|
pub fn warning_text(err : TitleValidationError) -> String {
  match err {
    EmptyTitle => "title cannot be empty"
    TooLong(length) => "title is too long (\{length}), max is 24"
    ForbiddenHash => "title cannot contain '#'"
  }
}

///|
pub impl Show for SubmitTitleResponse with output(self, logger) {
  let text = match self {
    Accepted(title) => "accepted: \{title}"
    ValidationError(err) => "validation_error: \{warning_text(err)}"
    InvalidJson => "invalid_json: invalid request json"
  }
  logger.write_string(text)
}

///|
pub extend SubmitTitleResponse with Show::{to_string, output}
```



## 步骤 3：实现前端（`js`）

前端行为：

- 用共享规则在本地校验标题
- 若通过校验，则向后端 `/submit` 发送 `POST`
- 展示后端响应文本

```
import {
  "moonbit-community/fullstack-one-project-doc/shared",
  "moonbitlang/core/json",
  "moonbit-community/rabbita",
  "moonbit-community/rabbita/html",
  "moonbit-community/rabbita/http" @rhttp,
}

supported_targets = "js"

pkgtype(kind: "executable")
```



```
fn main {
  let app = @rabbita.elmish(
    model={ title: "", warning: None, server_message: None },
    update=(model, msg, dispatch) => {
      match msg {
        Edit(title) => {
          let warning = local_warning(title)
          ({ title, warning, server_message: None }, @rabbita.none)
        }
        Submit =>
          match model.warning {
            Some(message) =>
              (
                { ..model, server_message: Some("not sent: \{message}") },
                @rabbita.none,
              )
            None => {
              let request = @shared.SubmitTitleRequest::{ title: model.title }
              let request_json = request.to_json().stringify()
              let cmd = @rhttp.post("http://127.0.0.1:8080/submit")
                .with_text(request_json)
                .expect_text(result => dispatch(ServerReplied(
                  result.map_err(err => err.to_string()),
                )))
              (
                { ..model, server_message: Some("sending json request...") },
                cmd,
              )
            }
          }
        ServerReplied(result) => {
          let server_message = match result {
            Ok(raw_json) =>
              try {
                let response : @shared.SubmitTitleResponse = @json.from_json(
                  @json.parse(raw_json),
                )
                Some("\{response}")
              } catch {
                _ => Some("invalid backend response json")
              }
            Err(err) => Some("request failed: \{err}")
          }
          ({ ..model, server_message, }, @rabbita.none)
        }
      }
    },
    view=(model, dispatch) => {
      let warning_line = match model.warning {
        Some(message) => p("warning: \{message}")
        None => p("local validation passed")
      }
      let server_line = match model.server_message {
        Some(response) => p("backend response: \{response}")
        None => p("backend response: (none yet)")
      }
      let value = model.title
      div([
        h2("Shared Validation Demo"),
        input(
          input_type=Text,
          value~,
          on_input=text => dispatch(Edit(text)),
        ),
        button(on_click=dispatch(Submit), "Submit as JSON"),
        warning_line,
        server_line,
      ])
    },
  )
  app.mount("app")
}
```



## 步骤 4：实现后端（`native`）

后端行为：

- 将 `GET /` 映射到静态文件 `backend/index.html`
- 将 `GET /frontend.js` 映射到前端构建产物
- 用共享校验处理 `POST /submit` 并返回 JSON 响应

```
import {
  "moonbit-community/fullstack-one-project-doc/shared",
  "moonbitlang/core/json",
  "moonbitlang/async",
  "moonbitlang/async/fs",
  "moonbitlang/async/http",
  "moonbitlang/async/socket",
  "moonbitlang/async/stdio",
}

supported_targets = "native"

pkgtype(kind: "executable")
```



```
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Shared Validation Demo</title>
  </head>
  <body>
    <h1>Shared Validation Demo</h1>
    <p>Backend serves this page and the built frontend bundle.</p>
    <div id="app"></div>
    <script src="/frontend.js"></script>
  </body>
</html>
```



```
async fn main {
  @stdio.stdout.write("starting backend on http://127.0.0.1:8080\n")
  let server = @http.Server(@socket.Addr::parse("127.0.0.1:8080")) catch {
    err => {
      @stdio.stdout.write("failed to start backend: \{err}\n")
      return
    }
  }

  server.run_forever((request, body, conn) => {
    match (request.meth, request.path) {
      (Get, "/") =>
        send_file(
          conn, index_html_path, html_headers, "missing backend/index.html",
        )
      (Get, "/frontend.js") =>
        send_file(
          conn, frontend_js_path, js_headers, "missing frontend bundle; run `moon build frontend --target js`",
        )
      (Post, "/submit") => {
        let raw_body = body.read_all().text() catch { _ => "" }
        let response : @shared.SubmitTitleResponse = try {
          let request : @shared.SubmitTitleRequest = @json.from_json(
            @json.parse(raw_body),
          )
          try {
            @shared.validate_request(request)
            @shared.SubmitTitleResponse::Accepted(
              request.title.trim().to_owned(),
            )
          } catch {
            err => @shared.SubmitTitleResponse::ValidationError(err)
          }
        } catch {
          _ => @shared.SubmitTitleResponse::InvalidJson
        }
        let code = match response {
          @shared.SubmitTitleResponse::Accepted(_) => 200
          _ => 400
        }
        let reason = if code == 200 { "OK" } else { "BadRequest" }
        conn
        ..send_response(code, reason, extra_headers=json_headers)
        ..write(response.to_json().stringify())
        .end_response()
      }
      _ =>
        conn
        ..send_response(404, "NotFound", extra_headers=text_headers)
        ..write("Not Found")
        .end_response()
    }
  })
}
```



## 步骤 5：使用 Makefile 快捷命令

```
.PHONY: help build-frontend run-backend check test api-test verify verify-all clean

help:
	@echo "Targets:"
	@echo "  make build-frontend  Build frontend JS bundle"
	@echo "  make run-backend     Run backend server on 127.0.0.1:8080"
	@echo "  make check           Run moon check for all targets"
	@echo "  make test            Run moon test for all targets"
	@echo "  make api-test        Run Hurl API tests against local backend"
	@echo "  make verify          Run check + test"
	@echo "  make verify-all      Run verify + api-test"
	@echo "  make clean           Remove build artifacts"

build-frontend:
	moon build frontend --target js

run-backend:
	moon run backend --target native

check:
	moon check --deny-warn --target all

test:
	moon test --deny-warn --target all

api-test: build-frontend
	@command -v hurl >/dev/null 2>&1 || { echo "hurl is required for api-test"; exit 1; }
	@set -eu; \
		moon run backend --target native >/tmp/fullstack-one-project-backend.log 2>&1 & \
		pid=$$!; \
		trap 'kill $$pid >/dev/null 2>&1 || true' EXIT INT TERM; \
		sleep 1; \
		hurl --test backend/api.hurl

verify: check test

verify-all: verify api-test

clean:
	rm -rf _build
```



常用工作流：

```
make build-frontend
make run-backend
```



然后在浏览器中打开 `http://127.0.0.1:8080/`。

## 步骤 6：用 Hurl 测试 API

Hurl 测试套件：

```
GET http://127.0.0.1:8080/
HTTP 200
[Asserts]
body contains "<div id=\"app\"></div>"

GET http://127.0.0.1:8080/frontend.js
HTTP 200
[Asserts]
body contains "function"

POST http://127.0.0.1:8080/submit
Content-Type: application/json
{
  "title": "Write docs"
}
HTTP 200
[Asserts]
jsonpath "$[0]" == "Accepted"
jsonpath "$[1]" == "Write docs"

POST http://127.0.0.1:8080/submit
Content-Type: application/json
{
  "title": "bad #title"
}
HTTP 400
[Asserts]
jsonpath "$[0]" == "ValidationError"
jsonpath "$[1]" == "ForbiddenHash"

POST http://127.0.0.1:8080/submit
Content-Type: application/json
{
  "title": "01234567890123456789012345"
}
HTTP 400
[Asserts]
jsonpath "$[0]" == "ValidationError"
jsonpath "$[1][0]" == "TooLong"
jsonpath "$[1][1]" == 26

POST http://127.0.0.1:8080/submit
Content-Type: application/json
​```
{"title":
​```
HTTP 400
[Asserts]
jsonpath "$" == "InvalidJson"
```



运行：

```
make api-test
```



这会验证：

- 静态 `GET /` 与 `GET /frontend.js`
- 合法提交（`200`）
- 标题非法时被拒绝提交（`400`）
- JSON 输入格式错误时被拒绝提交（`400`）

## 步骤 7：验证全部内容

```
make verify-all
```



会执行：

- `moon check --deny-warn --target all`
- `moon test --deny-warn --target all`
- Hurl API 测试

现在你已经有了一个可执行的项目：前后端共享同一套校验契约与错误模型。

# MoonBit（月兔）编程语言

MoonBit 是一个面向云与边缘计算的 AI 原生编程语言工具链。它支持 `wasm`、`wasm-gc`、`js` 与 `native` 目标，并且很适合在一个模块中开发混合后端项目。

**状态**

MoonBit 目前处于 beta-preview 阶段。

MoonBit 已经可以用于生产环境；任何不兼容的更改都会被严格评估，编译器错误也应当是罕见的。MoonBit 由一支在语言工具链方面经验深厚的全职团队开发，因此整个生态发展得很快。

**主要优势**

- 生成比现有解决方案明显更小的 Wasm 文件。
- 更高的运行时性能。
- 先进的编译时性能。
- 简单且实用的数据导向语言设计。

[下载本章节的 Markdown 版本](https://docs.moonbitlang.cn/_downloads/78d8998d78e60fd7b1b2f4c9bb2819fb/summary.md)

# 介绍

一个 MoonBit 程序由顶层定义组成，包括：

- 类型定义
- 函数定义
- 常数定义和变量绑定
- `init` 函数，`main` 函数和/或 `test` 块。

## 表达式和语句

MoonBit 区分语句和表达式。在函数体中，只有最后一个子句应该是一个表达式，它作为返回值。例如：

```
fn foo() -> Int32 {
  let x = 1
  x + 1
}

fn bar() -> Int32 {
  let x = 1
  //! x + 1
  x + 2
}
```



表达式包括：

- 值字面量（例如布尔值、数字、字符、字符串、数组、元组、结构体）
- 算术、逻辑或比较操作
- 访问数组元素（例如 `a[0]`），结构体字段（例如 `r.x`），元组组件（例如 `t.0`）等
- 变量和枚举构造器
- 匿名本地函数定义
- `match`，`if`，`loop` 表达式等。

语句包括：

- 命名本地函数定义
- 本地变量绑定
- 赋值
- `return` 语句
- 任何返回类型为 `Unit` 的表达式（例如 `ignore`）

代码块可以包含多个语句和一个表达式，表达式的值是代码块的值。

## 变量绑定

变量可以使用 `let mut` 或 `let` 声明为可变或不可变。可变变量可以重新赋值为新值，而不可变变量则不能。

常量只能在顶层声明，不能更改。

```
let zero = 0

const ZERO = 0

fn main {
  //! const ZERO = 0 
  let mut i = 10
  i = 20
  println(i + zero + ZERO)
}
```



备注

顶层变量绑定

- 需要 **显式** 类型注释（除非使用字符串、字节或数字等字面量定义）
- 不能是可变的（使用 `Ref` 代替）

## 命名约定

变量、函数应以小写字母 `a-z` 开头，可以包含字母、数字、下划线和其他非 ASCII 的 Unicode 字符。建议使用 snake_case 命名。

常量、类型应以大写字母 `A-Z` 开头，可以包含字母、数字、下划线和其他非 ASCII 的 Unicode 字符。建议使用 PascalCase 或 SCREAMING_SNAKE_CASE 命名。

### 关键字

以下是关键字，不应使用：

```
[
  "as", "else", "extern", "fn", "if", "let", "const", "match", "using",
  "mut", "type", "struct", "enum", "extenum", "trait",
  "derive", "while", "break", "continue", "import", "return",
  "throw", "raise", "try", "catch", "pub", "priv", "proof_assert", "proof_let",
  "readonly", "true", "false", "_", "test", "loop", "for", "in", "impl", "with",
  "guard", "async", "is", "suberror", "and", "letrec", "enumview", "noraise", "nocancel",
  "defer", "lexmatch", "lexscan", "where", "declare", "nobreak",
]
```



### 保留关键字

以下是保留关键字。使用它们会引入警告。它们可能在将来变成关键字。

```
[
  "module", "move", "ref", "static", "super", "unsafe", "use", "await",
  "dyn", "abstract", "do", "final", "macro", "override", "typeof", "virtual", "yield",
  "local", "method", "alias", "assert", "package", "recur", "using", "enumview",
  "isnot", "define", "downcast", "inherit", "member", "namespace", "static", "upcast",
  "use", "void", "lazy", "include", "mixin", "protected", "sealed", "constructor",
  "atomic", "volatile", "anyframe", "anytype", "asm", "await", "comptime", "errdefer",
  "export", "opaque", "orelse", "resume", "threadlocal", "unreachable", "dynclass",
  "dynobj", "dynrec", "var", "finally", "noasync", "assume", "extend",
]
```



## 程序入口

### `init` 和 `main`

有一个专门的函数称为 `init` 函数。`init` 函数是特殊的：

1. 它没有参数列表也没有返回类型。
2. 同一个包中可以有多个 `init` 函数。
3. `init` 函数不能被显式调用或被其他函数引用。相反，所有 `init` 函数将在初始化包时隐式调用。因此，`init` 函数应该只包含语句。

```
fn init {
  let x = 1
  println(x)
}
```



还有另一个专门的函数称为 `main` 函数。`main` 函数是程序的主入口，它将在初始化阶段之后执行。

与 `init` 函数相同，它没有参数列表也没有返回类型。

```
fn main {
  let x = 2
  println(x)
}
```



前两个代码片段将在运行时打印以下内容：

```
1
2
```



只有 `main` 包才能定义这样的 `main` 函数。查看 [构建系统教程](https://docs.moonbitlang.cn/toolchain/moon/tutorial.html) 了解详情。在当前项目中，这通过 `moon.pkg` 配置：

moon.pkg

```
pkgtype(kind: "executable")
```



### `test`

还有一个称为 `test` 块的顶级结构。`test` 块定义内联测试，例如：

```
test "test_name" {
  assert_eq(1 + 1, 2)
  assert_eq(2 + 2, 4)
  debug_inspect([1, 2, 3], content="[1, 2, 3]")
}
```



以下内容将使用 `test` 块和 `main` 函数来演示执行结果。我们假设所有 `test` 块都通过测试，除非另有说明。

# 基础

## 内置数据结构

### Unit

`Unit` 是 MoonBit 中的一个内置类型，它表示没有有意义的值。它只有一个值，写作 `()`。`Unit` 类似于 C/C++/Java 中的 `void`，但与 `void` 不同的是，它是一个真正的类型，可以在任何需要类型的地方使用。

`Unit` 类型通常用作执行某些操作但不产生有意义结果的函数的返回类型：

```
fn print_hello() -> Unit {
  println("Hello, world!")
}
```



与其他一些语言不同，MoonBit 将 `Unit` 视为一等类型，允许它在泛型中使用、存储在数据结构中以及作为函数参数传递。

### 布尔值

MoonBit 有一个内置的布尔类型，它有两个值：`true` 和 `false`。布尔类型用于条件表达式和控制结构。可以使用 `!` 对布尔值取反；`not(x)` 等价。

```
let a = true
let b = false
let c = a && b
let d = a || b
let e = !a
let f = !(a && b)
```



### 数字

MoonBit 有整数类型和浮点类型：

| 类型     | 描述                         | 示例                       |
| -------- | ---------------------------- | -------------------------- |
| `Int16`  | 16 位有符号整数              | `(42 : Int16)`             |
| `Int32`  | 32 位有符号整数              | `42`                       |
| `Int64`  | 64 位有符号整数              | `1000L`                    |
| `UInt16` | 16 位无符号整数              | `(14 : UInt16)`            |
| `UInt32` | 32 位无符号整数              | `14U`                      |
| `UInt64` | 64 位无符号整数              | `14UL`                     |
| `Double` | 64 位浮点数，由 IEEE754 定义 | `3.14`                     |
| `Float`  | 32 位浮点数                  | `(3.14 : Float)`           |
| `BigInt` | 表示比其他类型更大的数值     | `10000000000000000000000N` |

`Int` 和 `UInt` 仍可作为 `Int32` 和 `UInt32` 的别名使用。格式化工具会使用显式指明位宽的名称 `Int32` 和 `UInt32`。

MoonBit 还支持数字字面量，包括十进制、二进制、八进制和十六进制数字。

为了提高可读性，您可以在数字字面量中间放置下划线，例如 `1_000_000`。请注意，下划线可以放在数字中的任何位置，而不仅仅是每三位数字。

- 十进制数之间可以有下划线。

  默认情况下，整数字面量是有符号的 32 位数字。对于无符号数字，需要后缀 `U`；对于 64 位数字，需要后缀 `L`。

  ```
  let a = 1234
  let b : Int32 = 1_000_000 + a
  let unsigned_num       : UInt32   = 4_294_967_295U
  let large_num          : Int64  = 9_223_372_036_854_775_807L
  let unsigned_large_num : UInt64 = 18_446_744_073_709_551_615UL
  ```

  

- 二进制数有一个前导零，后跟字母 "B"，即 `0b`/`0B`。请注意，`0b`/`0B` 后的数字必须是 `0` 或 `1`。

  ```
  let bin = 0b110010
  let another_bin = 0B110010
  ```

  

- 八进制数有一个前导零，后跟字母 "O"，即 `0o`/`0O`。请注意，`0o`/`0O` 后的数字必须在 `0` 到 `7` 的范围内：

  ```
  let octal = 0o1234
  let another_octal = 0O1234
  ```

  

- 十六进制数有一个前导零，后跟字母 "X"，即 `0x`/`0X`。请注意，`0x`/`0X` 后的数字必须在 `0123456789ABCDEF` 范围内。

  ```
  let hex = 0XA
  let another_hex = 0xA_B_C
  ```

  

- 浮点数字面量是 64 位浮点数。要定义一个浮点数，需要类型注释。

  ```
  let double = 3.14 // Double
  let float : Float = 3.14
  let float2 = (3.14 : Float)
  ```

  

  64 位浮点数也可以使用十六进制格式定义：

  ```
  let hex_double = 0x1.2P3 // (1.0 + 2 / 16) * 2^(+3) == 9
  ```

  

当期望的类型已知时，MoonBit 可以自动重载字面量，无需通过字母后缀指定数字的类型：

```
let int : Int32 = 42
let uint : UInt32 = 42
let int64 : Int64 = 42
let double : Double = 42
let float : Float = 42
let bigint : BigInt = 42
```



参见

[重载字面量](https://docs.moonbitlang.cn/language/fundamentals.html#overloaded-literals)

### 字符串

`String` 包含一系列 UTF-16 码点。您可以使用双引号创建字符串，或使用 `#|` 编写多行字符串。

```
let a = "兔rabbit"
debug_inspect(a.code_unit_at(0).to_char(), content="Some('兔')")
debug_inspect(a.code_unit_at(1).to_char(), content="Some('r')")
let b =
  #| Hello
  #| MoonBit\n
  #|
println(b)
```



输出

```
 Hello
 MoonBit\n
```



在双引号字符串中，反斜杠后跟某些特殊字符形成转义序列：

| 转义序列               | 描述                         |
| ---------------------- | ---------------------------- |
| `\n`, `\r`, `\t`, `\b` | 换行，回车，水平制表符，退格 |
| `\\`                   | 反斜杠                       |
| `\u5154` , `\u{1F600}` | Unicode 转义序列             |

MoonBit 支持字符串插值。它允许您在插值字符串中替换变量。此功能通过直接将变量值嵌入文本来简化构建动态字符串的过程。用于字符串插值的变量必须实现 [`Show` 特征](https://docs.moonbitlang.cn/language/methods.html#builtin-traits)。

```
let x = 42
println("The answer is \{x}")
```



备注

插值表达式不能包含换行符、`{}` 或 `"`。

多行字符串可以使用前缀 `#|` 或 `$|` 定义，其中前者将保留原始字符串，后者将执行转义和插值：

```
let lang = "MoonBit"
let raw =
  #| Hello
  #| ---
  #| \{lang}
  #| ---
let interp =
  $| Hello
  $| ---
  $| \{lang}
  $| ---
println(raw)
println(interp)
```



输出

```
 Hello
 ---
 \{lang}
 ---
 Hello
 ---
 MoonBit
 ---
```



避免在同一个多行字符串中混用 `$|` 和 `#|`；请在整个块中选择一种风格。

[VSCode 扩展](https://docs.moonbitlang.cn/toolchain/vscode/index.html#actions) 包含一个操作，可将粘贴的文档转换为普通的多行字符串，并在纯文本与 MoonBit 多行字符串之间切换。

当期望类型是 `String` 时，数组字面量被重载为字符串。你可以通过单独列出每个字符来构造`String`。

```
test {
  let c : Char = '中'
  let s : String = [c, '文']
  inspect(s, content="中文")
}
```



参见

API: https://mooncakes.io/docs/moonbitlang/core/string

[重载字面量](https://docs.moonbitlang.cn/language/fundamentals.html#overloaded-literals)

### 字符

`Char` 表示一个 Unicode 码点。

```
let a : Char = 'A'
let b = '兔'
let zero = '\u{30}'
let zero = '\u0030'
```



当期望类型是 `Int32` 或 `UInt16` 时，字符字面量可以重载为对应类型：

```
test {
  let s : String = "hello"
  let b : UInt16 = s.code_unit_at(0) // 'h'
  assert_eq(b, 'h') // 'h' 被重载为 UInt16
  let c : Int32 = '兔'
  // 不可：超出范围
  // let d : UInt16 = '𠮷'
}
```



参见

API: https://mooncakes.io/docs/moonbitlang/core/char

[重载字面量](https://docs.moonbitlang.cn/language/fundamentals.html#overloaded-literals)

### 字节

MoonBit 中的字节字面量是一个 ASCII 字符或一个转义序列，语法形式为 `b'...'`。字节字面量的类型是 `Byte`。例如：

```
fn main {
  let b1 : Byte = b'a'
  println(b1.to_int())
  let b2 = b'\xff'
  println(b2.to_int())
}
```



输出

```
97
255
```



`Bytes` 是不可修改的字节序列。与字节类似，字节序列字面量的形式是 `b"..."`。例如：

```
test {
  let b1 : Bytes = b"abcd"
  let b2 = b"\x61\x62\x63\x64"
  assert_eq(b1, b2)
}
```



Bytes 字面量支持使用 `b"...\{expression}"` 进行插值。插值后的字符串会编码为 UTF-8，生成 `Bytes`：

```
test {
  let value = 42
  let bytes : Bytes = b"value=\{value}"
  assert_eq(bytes, b"value=42")
}
```



模板写入语法也接受带插值的 Bytes 字面量。

`Byte`字面量和`Bytes`字面量也支持转义序列，但是和字符串字面量的转义序列有些不同。下面的表格列出了支持的转义序列：

| 转义序列               | 描述                         |
| ---------------------- | ---------------------------- |
| `\n`, `\r`, `\t`, `\b` | 换行，回车，水平制表符，退格 |
| `\\`                   | 反斜杠                       |
| `\x41`                 | 十六进制转义序列             |
| `\o102`                | 八进制转义序列               |

备注

你可以通过向`@buffer.T`写入不同类型的数据来构造一个`Bytes`。例如：

```
test "buffer 1" {
  let buf : @buffer.Buffer = Buffer()
  buf.write_bytes(b"Hello")
  buf.write_byte(b'!')
  assert_eq(buf.contents(), b"Hello!")
}
```



数组字面量也可以通过指定序列中的每个字节，重载为 `Bytes` 序列。

```
test {
  let b : Byte = b'\xFF'
  let bs : Bytes = [b, b'\x01']
  inspect(
    bs,
    content=(
      #|b"\xff\x01"
    ),
  )
}
```



参见

`Byte` 的 API：https://mooncakes.io/docs/moonbitlang/core/byte
`Bytes` 的 API：https://mooncakes.io/docs/moonbitlang/core/bytes
`@buffer.T` 的 API：https://mooncakes.io/docs/moonbitlang/core/buffer

[重载字面量](https://docs.moonbitlang.cn/language/fundamentals.html#overloaded-literals)

#### 选择字节容器

MoonBit 有几种面向字节的容器类型。它们彼此相关，但用途并不相同：

| 类型                 | 所有权 / 可变性        | 可否扩容 | 典型用途                                     |
| -------------------- | ---------------------- | -------- | -------------------------------------------- |
| `Bytes`              | 拥有所有权，不可变     | 否       | 最终字节负载、API 边界、序列化后的数据       |
| `BytesView`          | 借用的不可变视图       | 否       | 在不复制的情况下切片或解析已有字节数据       |
| `Array[Byte]`        | 拥有所有权，可变       | 是       | 通用的可变字节存储                           |
| `FixedArray[Byte]`   | 拥有所有权，可变       | 否       | 定长工作缓冲区                               |
| `ArrayView[Byte]`    | 借用的数组视图         | 否       | 在不转移所有权的情况下传递基于数组的字节切片 |
| `MutArrayView[Byte]` | 借用的可变视图         | 否       | 原地修改借用的、基于数组的字节存储           |
| `@buffer.Buffer`     | 拥有所有权的可变构造器 | 是       | 逐步构造字节数据，最后调用 `contents()`      |

有两个常见区别尤其重要：

- `Bytes` 与 `BytesView`：前者是拥有所有权的不可变数据，后者是借用的不可变切片。
- `Array[Byte]` 与 `ArrayView[Byte]` / `MutArrayView[Byte]`：前者是拥有所有权的可变存储，后者是其上的借用只读视图或可变视图。

当你需要显式表达这些约束时，可以使用对应的只读和可变视图类型：`ReadOnlyArray[Byte]` 与 `MutArrayView[Byte]`。模式匹配和位串解析同样适用于这些字节容器；参见 [数组模式](https://docs.moonbitlang.cn/language/fundamentals.html#array-pattern) 和 [位串模式](https://docs.moonbitlang.cn/language/fundamentals.html#bitstring-pattern)。

### 元组

元组是使用圆括号 `()` 构造的有限值集合，元素之间用逗号 `,` 分隔。元素的顺序很重要；例如，`(1,true)` 和 `(true,1)` 有不同的类型。以下是一个示例：

```
fn main {
  fn pack(
    a : Bool,
    b : Int32,
    c : String,
    d : Double
  ) -> (Bool, Int32, String, Double) {
    (a, b, c, d)
  }

  let quad = pack(false, 100, "text", 3.14)
  let (bool_val, int_val, str, float_val) = quad
  println("\{bool_val} \{int_val} \{str} \{float_val}")
}
```



输出

```
false 100 text 3.14
```



元组可以通过模式匹配或索引访问：

```
test {
  let t = (1, 2)
  let (x1, y1) = t
  let x2 = t.0
  let y2 = t.1
  assert_eq(x1, x2)
  assert_eq(y1, y2)
}
```



### Ref

`Ref[T]` 是一个包含类型 `T` 的值 `val` 的可变引用。

可以使用 `{ val : x }` 构造它，并可以使用 `ref.val` 访问它。有关详细说明，请参见 [结构体](https://docs.moonbitlang.cn/language/fundamentals.html#struct)。

```
let a : Ref[Int32] = { val: 100 }

test {
  a.val = 200
  assert_eq(a.val, 200)
  a.val += 1
  assert_eq(a.val, 201)
}
```



参见

API: https://mooncakes.io/docs/moonbitlang/core/ref

### Option 和 Result

`Option` 和 `Result` 是 MoonBit 中表示可能的错误或失败的最常见类型。

- `Option[T]` 表示可能缺失的类型 `T` 的值。它可以缩写为 `T?`。
- `Result[T, E]` 表示类型 `T` 的值或类型 `E` 的错误。

有关详细说明，请参见 [枚举](https://docs.moonbitlang.cn/language/fundamentals.html#enum)。

```
test {
  let a : Int32? = None
  let b : Option[Int32] = Some(42)
  let c : Result[Int32, String] = Ok(42)
  let d : Result[Int32, String] = Err("error")
  match a {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
  match d {
    Ok(_) => assert_true(false)
    Err(_) => assert_true(true)
  }
}
```



参见

`Option` 的 API：https://mooncakes.io/docs/moonbitlang/core/option
`Result` 的 API：https://mooncakes.io/docs/moonbitlang/core/result

### 数组

数组是使用方括号 `[]` 构造的有限值序列，元素之间用逗号 `,` 分隔。例如：

```
let numbers = [1, 2, 3, 4]
```



您可以使用 `numbers[x]` 来引用第 x 个元素。索引从零开始。

```
test {
  let numbers = [1, 2, 3, 4]
  let a = numbers[2]
  numbers[3] = 5
  let b = a + numbers[3]
  assert_eq(b, 8)
}
```



有 `Array[T]` 和 `FixedArray[T]`。视图类型为 `ArrayView[T]` 和 `MutArrayView[T]`（见下文）。

`Array[T]` 可以增长，`FixedArray[T]` 有固定的大小，因此需要使用初始值创建。

警告

一个常见的陷阱是使用相同的初始值创建 `FixedArray`：

```
test {
  let two_dimension_array = FixedArray::make(10, FixedArray::make(10, 0))
  two_dimension_array[0][5] = 10
  assert_eq(two_dimension_array[5][5], 10)
}
```



这是因为所有单元格引用相同的对象（在这种情况下是 `FixedArray[Int32]`）。应该使用 `FixedArray::makei()`，它为每个索引创建一个对象。

```
test {
  let two_dimension_array = FixedArray::makei(10, fn(_i) {
    FixedArray::make(10, 0)
  })
  two_dimension_array[0][5] = 10
  assert_eq(two_dimension_array[5][5], 0)
}
```



当期望的类型已知时，MoonBit 可以自动重载数组，否则将创建 `Array[T]`：

```
let fixed_array_1 : FixedArray[Int32] = [1, 2, 3]

let fixed_array_2 = ([1, 2, 3] : FixedArray[Int32])

let array_3 : Array[Int32] = [1, 2, 3] // Array[Int32]
```



参见

API: https://mooncakes.io/docs/moonbitlang/core/array

[重载字面量](https://docs.moonbitlang.cn/language/fundamentals.html#overloaded-literals)

#### ArrayView

类似于其他语言中的 `slice`，视图是对集合的特定段的引用。您可以使用 `data[start:end]` 创建数组 `data` 的视图，引用从 `start` 到 `end`（不包括）的元素。`start` 和 `end` 索引都可以省略。

备注

`ArrayView` 本身是一个不可变的数据结构，但底层的 `Array` 或 `FixedArray` 可以被修改。需要可变视图时，请使用 `data.mut_view(...)` 获取 `MutArrayView[T]`。

```
test {
  let xs = [0, 1, 2, 3, 4, 5]
  let s1 : ArrayView[Int32] = xs[2:]
  @test.assert_eq(s1.to_owned(), [2, 3, 4, 5])
  @test.assert_eq(xs[:4].to_owned(), [0, 1, 2, 3])
  @test.assert_eq(xs[2:5].to_owned(), [2, 3, 4])
  @test.assert_eq(xs[:].to_owned(), [0, 1, 2, 3, 4, 5])
  let mv : MutArrayView[Int32] = xs.mut_view(start=1, end=3)
  mv[0] = 99
  inspect(xs[1], content="99")
}
```



参见

API: https://mooncakes.io/docs/moonbitlang/core/array

### Map

MoonBit 在其标准库中提供了一个保留插入顺序的哈希映射数据结构，称为 `Map`。`Map` 可以通过方便的字面量语法创建：

```
let map : Map[String, Int32] = { "x": 1, "y": 2, "z": 3 }
```



目前，映射字面量语法中的键必须是常量。`Map` 也可以通过模式匹配优雅地解构，参见 [Map 模式](https://docs.moonbitlang.cn/language/fundamentals.html#map-pattern)。

参见

API: https://mooncakes.io/docs/moonbitlang/core/builtin#Map

[重载字面量](https://docs.moonbitlang.cn/language/fundamentals.html#overloaded-literals)

### Json

MoonBit 通过重载字面量支持方便的 json 处理。当表达式的期望类型是 `Json` 时，数字、字符串、数组和映射字面量可以直接用于创建 json 数据：

```
let moon_pkg_json_example : Json = {
  "import": ["moonbitlang/core/builtin", "moonbitlang/core/coverage"],
  "test-import": ["moonbitlang/core/random"],
}
```



Json 值也可以进行模式匹配，参见 [Json 模式](https://docs.moonbitlang.cn/language/fundamentals.html#json-pattern)。

参见

API: https://mooncakes.io/docs/moonbitlang/core/json

[重载字面量](https://docs.moonbitlang.cn/language/fundamentals.html#overloaded-literals)

## 重载字面量

Overloaded literals allow you to use the same syntax to represent different types of values.

空的 `{}` 字面量存在歧义：它可能表示空映射、空 JSON 对象、空记录或块。请分别显式写成 `Map([])`、`Json::empty_object()`、`Record::{}` 或 `{ () }`。例如，根据期望类型，可以用 `1` 表示 `UInt32` 或 `Double`；如果期望类型未知，则默认解释为 `Int32`。

```
fn expect_double(x : Double) -> Unit {

}

test {
  let x = 1 // type of x is Int32
  let y : Double = 1
  expect_double(1)
}
```



重载字面量可以组合使用。如果一个数组字面量能够被重载为`Bytes`类型，并且一个数字字面量可以被重载为`Byte`类型，那么`[1,2,3]`就可以被重载为`Bytes`。下面的表格列出了可以重载的字面量和规则：

| 重载字面量                               | 默认类型   | 可以被重载为                                                 |
| ---------------------------------------- | ---------- | ------------------------------------------------------------ |
| `10`, `0xFF`, `0o377`, `10_000`          | `Int32`    | `UInt32`, `Int64`, `UInt64`, `Int16`, `UInt16`, `Byte`, `Double`, `Float`, `BigInt` |
| `"str"`                                  | `String`   | —                                                            |
| `'c'`                                    | `Char`     | `Int32`                                                      |
| `3.14`                                   | `Double`   | `Float`                                                      |
| `[a, b, c]`（字面量 a、b、c 的类型为 E） | `Array[E]` | `FixedArray[E]`、`String`（如果 E 的类型是 Char）、`Bytes`（如果 E 的类型是 Byte） |

在模式中也有类似的重载规则，更多细节见 [模式匹配](https://docs.moonbitlang.cn/language/fundamentals.html#pattern-matching)。

备注

字面量重载不是值转换。如果要将一个变量转换为不同的类型的值，可以使用以`to_`开头的方法，例如`to_int()`和`to_double()`，等等。

### 重载字面量中的转义序列

转义序列能在重载的`"..."`和`'...'`字面量中使用。转义序列的解释根据它被重载到的具体类型而定：

- 简单转义序列

  包括`\n`、`\r`、`\t`、`\\`和`\b`。这些转义序列在任何`"..."`和`'...'`字面量中都被支持。在期望的类型是`String`时，它们被解释为对应的字符；在期望的类型是`Bytes`时，它们被解释为对应的`Byte`。

- 字节转义序列

  `\x41`和`\o102`转义序列表示一个`Byte`值。支持在重载为`Bytes`和`Byte`类型的字面量中使用。

- Unicode 转义序列

  `\u5154`和`\u{1F600}`转义序列表示一个`Char`。支持在重载为`String`和`Char`类型的字面量中使用。

## 函数

函数接受参数并产生结果。在 MoonBit 中，函数是一等公民，这意味着函数可以是其他函数的参数或返回值。MoonBit 的命名约定要求函数名不应以大写字母（A-Z）开头。请参见下面的 `enum` 部分中的构造器。

### 顶层函数

函数可以定义为顶级或局部。我们可以使用 `fn` 关键字定义一个顶级函数，它将三个整数相加并返回结果，如下所示：

```
fn add3(x : Int32, y : Int32, z : Int32) -> Int32 {
  x + y + z
}
```



请注意，顶级函数的参数和返回值需要**显式**类型注释。

顶层函数和方法也可以使用 `declare` 引入。声明函数只有签名而没有函数体，后续实现必须与该签名匹配。当你想先提供 API 形状、稍后再放置实现时，这很有用。

```
declare fn declared_add(x : Int32, y : Int32) -> Int32

fn declared_add(x : Int32, y : Int32) -> Int32 {
  x + y
}

struct DeclaredCounter(Int32)

declare fn DeclaredCounter::value(self : Self) -> Int32

fn DeclaredCounter::value(self : Self) -> Int32 {
  self.0
}

test "declared functions" {
  @test.assert_eq(declared_add(1, 2), 3)
  @test.assert_eq(DeclaredCounter(4).value(), 4)
}
```



如果声明函数有实现，声明和实现必须在函数名、可见性、类型参数、参数、返回类型和 effect 上保持一致。

顶层值也可以使用 `declare let name : Type` 声明。请在同一个包中提供对应的 `let` 定义：

```
///|
declare pub let default_limit : Int32

///|
pub let default_limit : Int32 = 100
```



`#alias` 应放在定义上，而不是 `declare fn` 或 `declare let` 声明上。

### 局部函数

局部函数可以是命名的或匿名的。局部函数定义可以省略类型注释：在大多数情况下，它们可以自动推断。例如：

```
fn local_1() -> Int32 {
  fn inc(x) { // 命名为 `inc`
    x + 1
  }
  // 匿名，立即应用于整数字面量 6
  (fn(x) { x + inc(2) })(6)
}

test {
  assert_eq(local_1(), 9)
}
```



MoonBit 为简单的匿名函数提供了一个非常简洁的箭头函数语法：

```
  [1, 2, 3].eachi((i, x) => println("\{i} => \{x}"))
  // 只有一个参数时可以省略括号
  [1, 2, 3].each(x => println(x * x))
```



尽管非顶层的函数支持自动推导参数和返回值的类型，只有箭头函数语法允许推导副作用。如果一个 `fn` 可能 [抛出错误](https://docs.moonbitlang.cn/language/error-handling.html) 或 [进行异步操作](https://docs.moonbitlang.cn/language/async-experimental.html)，那么这个 `fn` 必须有显式的 `raise` 或 `async` 标记。

函数，无论是命名的还是匿名的，都是 *词法闭包*：没有局部绑定的任何标识符必须引用来自周围词法范围的绑定。例如：

```
let global_y = 3

fn local_2(x : Int32) -> (Int32, Int32) {
  fn inc() {
    x + 1
  }

  fn four() {
    global_y + 1
  }

  (inc(), four())
}

test {
  @test.assert_eq(local_2(3), (4, 4))
}
```



局部函数的定义内，可以使用这个函数自己或者之前定义的其他局部函数。如果要定义多个互相递归的局部函数，需要使用 `letrec f = .. and g = ..` 语法：

```
  fn f(x) {
    // `f` 可以调用它自己，但不能调用 `g`
    if x > 0 {
      f(x - 1)
    }
  }

  fn g(x) {
    // `g` 可以调用 `f` 和 `g` 自身
    if x < 0 {
      f(-x)
    } else {
      f(x)
    }
  }
  // 互递归的局部函数
  letrec even = x => x == 0 || odd(x - 1)
  and odd = x => x != 0 && even(x - 1)
```



### 函数应用

函数可以应用于括号中的参数列表：

```
add3(1, 2, 7)
```



无论 `add3` 是一个使用名称定义的函数（如前面的示例）还是绑定到函数值的变量，都可以工作，如下所示：

```
test {
  let add3 = fn(x, y, z) { x + y + z }
  assert_eq(add3(1, 2, 7), 10)
}
```



表达式 `add3(1, 2, 7)` 返回 `10`。任何求值为函数值的表达式都是可应用的：

```
test {
  let f = fn(x) { x + 1 }
  let g = fn(x) { x + 2 }
  let w = (if true { f } else { g })(3)
  assert_eq(w, 4)
}
```



### 部分应用

部分应用允许函数调用时只提供部分的参数，生成一个接受被余下的参数并返回结果的函数。在 MoonBit 中，通过`_`操作符可以对函数进行部分应用：

```
fn add(x : Int32, y : Int32) -> Int32 {
  x + y
}

test {
  let add10 : (Int32) -> Int32 = x => add(10, x)
  println(add10(5)) // 输出 15
  println(add10(10)) // 输出 20
}
```



`_`操作符表示括号中缺少的参数。部分应用允许在一对括号中使用多个`_`。例如，`Array::fold(_, _, init=5)`等价于`fn(x, y) { Array::fold(x, y, init=5) }`。

`_`操作符也可以在创建枚举值、`self.f(args)`形式的函数调用和管道中使用。

警告

用于部分应用的 `f(a, _, b)` 语法已弃用。请改用 `x => f(a, x, b)`。

### 带标签的参数

**顶层**函数可以使用语法 `label~ : Type` 声明带标签的参数。`label` 也将作为函数体内的参数名：

```
fn labelled_1(arg1~ : Int32, arg2~ : Int32) -> Int32 {
  arg1 + arg2
}
```



可以通过语法 `label=arg` 提供带标签的参数。`label=label` 可以缩写为 `label~`：

```
test {
  let arg1 = 1
  assert_eq(labelled_1(arg2=2, arg1~), 3)
}
```



带标签的函数可以以任何顺序提供。参数的求值顺序与函数声明中参数的顺序相同。

### 可选参数

可以用 `label~ : Type = default_expr` 语法为参数提供默认表达式，使其成为可选参数。调用时若未提供该参数，就会使用默认表达式。不指定显式默认值的可选参数使用 `label? : Type`（见下文）。

```
fn optional(opt~ : Int32 = 42) -> Int32 {
  opt
}

test {
  assert_eq(optional(), 42)
  assert_eq(optional(opt=0), 0)
}
```



默认表达式每次使用时都会被求值。并且默认表达式中的副作用（如果有）也会被触发。例如：

```
fn incr(counter~ : Ref[Int32] = { val: 0 }) -> Ref[Int32] {
  counter.val = counter.val + 1
  counter
}

test {
  @test.assert_eq(incr().val, 1)
  @test.assert_eq(incr().val, 1)
  let counter = Ref::{ val: 0 }
  @test.assert_eq(incr(counter~).val, 1)
  @test.assert_eq(incr(counter~).val, 2)
}
```



可选参数在调用处就是普通表达式。在 `raise` 或 `async` 上下文中，你可以传入可能抛错或调用异步函数的表达式：

```
fn may_fail(x : Int32) -> Int32 raise Failure {
  if x < 0 {
    fail("negative")
  }
  x
}

fn add_with_optional(base : Int32, extra~ : Int32 = 1) -> Int32 {
  base + extra
}

test {
  inspect(add_with_optional(1, extra=may_fail(2)), content="3")
}
```



对于 async 函数，可选参数表达式同样可以调用异步函数：

```
///|
async fn fetch_default() -> Int32 {
  ...
}

///|
async fn build(x~ : Int32 = fetch_default()) -> Int32 {
  ...
}

///|
async fn use_value() -> Int32 {
  build(x=fetch_default())
}
```



如果要在不同的函数调用之间共享默认表达式的结果，可以将默认表达式提升到顶层 `let` 声明：

```
let default_counter : Ref[Int32] = { val: 0 }

fn incr_2(counter~ : Ref[Int32] = default_counter) -> Int32 {
  counter.val = counter.val + 1
  counter.val
}

test {
  assert_eq(incr_2(), 1)
  assert_eq(incr_2(), 2)
}
```



默认表达式可以依赖于之前的参数，例如：

```
fn create_rectangle(a : Int32, b~ : Int32 = a) -> (Int32, Int32) {
  (a, b)
}

test {
  debug_inspect(create_rectangle(10), content="(10, 10)")
}
```



#### 没有默认值的可选参数

当用户未提供值时，具有不同语义的情况是很常见的。没有默认值的可选参数的类型为 `T?`，默认值为 `None`。在直接提供这种可选参数时，MoonBit 将自动用 `Some` 包装该值：

```
fn new_image(width? : Int32, height? : Int32) -> Image {
  if width is Some(w) {
    ...
  }
  ...
}

let img2 : Image = new_image(width=1920, height=1080)
```



有时，直接传递类型为 `T?` 的值也很有用，例如在转发可选参数时。MoonBit 为此提供了一个语法 `label?=value`，并且 `label?` 是 `label?=label` 的缩写：

```
fn image(width? : Int32, height? : Int32) -> Image {
  ...
}

fn fixed_width_image(height? : Int32) -> Image {
  image(width=1920, height?)
}
```





### 自动填充参数

MoonBit 支持在不同的调用位置自动填充特定类型的参数，例如函数调用的源位置。要声明一个自动填充参数，只需声明一个带标签的参数，并添加一个函数属性 `#callsite(autofill(param_a, param_b))`。现在，如果未显式提供参数，MoonBit 将在调用时自动填充它。

目前 MoonBit 支持两种类型的自动填充参数，`SourceLoc`，它是整个函数调用的源位置，以及 `ArgsLoc`，它是一个数组，包含每个参数的源位置（如果有）：

```
#callsite(autofill(loc, args_loc))
fn f(_x : Int32, loc~ : SourceLoc, args_loc~ : ArgsLoc) -> String {
  (
    $|loc of whole function call: \{loc}
    $|loc of arguments: \{args_loc}
  )
  // 整个函数调用的位置：<filename>:7:3-7:10
  // 参数的位置：[Some(<filename>:7:5-7:6), Some(<filename>:7:8-7:9), None, None]
}
```



自动填充参数非常有用，用于编写调试和测试工具。

### 函数别名

MoonBit 允许用户用别名来调用一个函数。声明函数别名的语法如下：

```
#alias(g)
#alias(h, visibility="pub")
fn k() -> Bool {
  true
}
```



你也可以通过字段 `visibility` 创建具有不同可见性的函数别名。

## 控制结构

### 条件表达式

条件表达式由条件、结果和可选的 `else` 子句或 `else if` 子句组成。

```
if x == y {
  expr1
} else if x == z {
  expr2
} else {
  expr3
}
```



结果周围的大括号是必需的。

请注意，条件表达式在 MoonBit 中始终返回一个值，结果和 else 子句的返回值必须是相同的类型。以下是一个示例：

```
let initial = if size < 1 { 1 } else { size }
```



`else` 子句只有在返回值的类型为 `Unit`的时候省略。

### 匹配表达式

`match` 表达式类似于条件表达式，但它使用 [模式匹配](https://docs.moonbitlang.cn/language/fundamentals.html#pattern-matching) 来决定要评估哪个结果，并同时提取变量。

```
fn decide_sport(weather : String, humidity : Int32) -> String {
  match weather {
    "sunny" => "tennis"
    "rainy" => if humidity > 80 { "swimming" } else { "football" }
    _ => "unknown"
  }
}

test {
  assert_eq(decide_sport("sunny", 0), "tennis")
}
```



如果省略了可能的条件，编译器将发出警告；如果真的出现该情况，程序将终止。

### 卫语句

`guard` 语句用于检查指定的不变量。如果不变量的条件得到满足，程序将继续执行后续语句。如果条件不满足（即为假），则执行 `else` 块中的代码且返回其值（并跳过后续语句）。

```
fn guarded_get(array : Array[Int32], index : Int32) -> Int32? {
  guard index >= 0 && index < array.length() else { None }
  Some(array[index])
}

test {
  debug_inspect(guarded_get([1, 2, 3], -1), content="None")
}
```



#### 卫语句与 is 表达式

`let` 语句可以与 [模式匹配](https://docs.moonbitlang.cn/language/fundamentals.html#pattern-matching) 一起使用。但是，`let` 语句只能处理一种情况。使用 [is 表达式](https://docs.moonbitlang.cn/language/fundamentals.html#is-expression) 配合卫语句可以解决这个问题。

在以下示例中，`getProcessedText` 假设输入的 `path` 指向的资源都是纯文本，并使用 `guard` 语句来在确保这个不变量的同时，解构出纯文本资源。与使用 `match` 语句相比，`text` 的后续处理可以少一级缩进。

```
enum Resource {
  Folder(Array[String])
  PlainText(String)
  JsonConfig(Json)
}

fn getProcessedText(
  resources : Map[String, Resource],
  path : String,
) -> String raise Error {
  guard resources.get(path) is Some(resource) else { fail("\{path} not found") }
  guard resource is PlainText(text) else { fail("\{path} is not plain text") }
  process(text)
}
```



可能失败的普通 `guard` 必须带有 `else` 子句。如果编译器无法证明不带 `else` 的 `guard` 一定成功，就会报告 [E0087](https://docs.moonbitlang.cn/language/error_codes/E0087.html)，因为失败会隐式终止程序。如果本来就需要终止程序，请使用 `guard!`。与 `guard` 不同，`guard!` 不能带有 `else` 子句。

```
guard! condition  // <=> guard condition else { panic() }
guard! expr is Some(x)
// <=> guard expr is Some(x) else { _ => panic() }
```



当条件或模式已经穷尽时，应使用不带 `else` 的普通 `guard`。多余的 `!` 或 `else` 子句会触发编译器警告。

```
fn require_some(value : Int32?) -> Int32 {
  guard! value is Some(result)
  result
}
```



### While 循环

在 MoonBit 中，`while` 循环可用于在条件为真时重复执行一段代码块。在执行代码块之前，将评估条件。使用 `while` 关键字定义 `while` 循环，后跟条件和循环体。循环体是一系列语句。只要条件为真，就会执行循环体。

```
fn main {
  let mut i = 5
  while i > 0 {
    println(i)
    i = i - 1
  }
}
```



输出

```
5
4
3
2
1
```



循环体支持 `break` 和 `continue`。使用 `break` 可以退出当前循环，而使用 `continue` 则跳过当前迭代的剩余部分并继续下一次迭代。

```
fn main {
  let mut i = 5
  while i > 0 {
    i = i - 1
    if i == 4 {
      continue
    }
    if i == 1 {
      break
    }
    println(i)
  }
}
```



输出

```
3
2
```



`while` 循环还支持可选的 `nobreak` 子句。当循环条件变为假时，将执行 `nobreak` 子句，然后循环将结束。

```
fn main {
  let mut i = 2
  while i > 0 {
    println(i)
    i = i - 1
  } nobreak {
    println(i)
  }
}
```



输出

```
2
1
0
```



当有 `nobreak` 子句时，`while` 循环还可以返回一个值。返回值是 `nobreak` 子句的评估结果。在这种情况下，如果使用 `break` 退出循环，需要在 `break` 后提供一个返回值，该返回值应与 `nobreak` 子句的返回值类型相同。

```
fn main {
  let mut i = 10
  let r = while i > 0 {
    i = i - 1
    if i % 2 == 0 {
      break 5
    }
  } nobreak {
    7
  }
  println(r)
}
```



输出

```
5
```



```
fn main {
  let mut i = 10
  let r = while i > 0 {
    i = i - 1
  } nobreak {
    7
  }
  println(r)
}
```



输出

```
7
```



### For 循环

MoonBit 还支持 C 风格的 For 循环。关键字 `for` 后跟由分号分隔的变量初始化子句、循环条件和更新子句。它们不需要用括号括起来。例如，下面的代码创建了一个新的变量绑定 `i`，它在整个循环中都有作用域且是不可变的。这使得编写清晰的代码并对其进行推理更容易：

```
fn main {
  for i = 0; i < 5; i = i + 1 {
    println(i)
  }
}
```



输出

```
0
1
2
3
4
```



变量初始化子句可以创建多个绑定：

```
for i = 0, j = 0; i + j < 100; i = i + 1, j = j + 1 {
  println(i)
}
```



应该注意，在更新子句中，当有多个绑定变量时，语义是同时更新它们。换句话说，在上面的示例中，更新子句不会按顺序执行 `i = i + 1`，`j = j + 1`，而是同时递增 `i` 和 `j`。因此，在更新子句中读取绑定变量的值时，总是会得到上一次迭代中更新的值。

变量初始化子句、循环条件和更新子句都是可选的。例如，以下两个是无限循环：

```
for i = 1; ; i = i + 1 {
  println(i)
}
for ;; {
  println("loop forever")
}
```



`for` 循环还支持 `continue`、`break` 和 `nobreak` 子句。与 `while` 循环一样，`for` 循环也可以使用 `break` 和 `nobreak` 子句返回一个值。

`continue` 语句跳过当前 `for` 循环的剩余部分（包括更新子句）并继续下一次迭代。`continue` 语句还可以更新 `for` 循环的绑定变量，只要后面跟着与绑定变量数量匹配的表达式，用逗号分隔。

例如，以下程序计算从 1 到 6 的偶数之和：

```
fn main {
  let sum = for i = 1, acc = 0; i <= 6; i = i + 1 {
    if i % 2 == 0 {
      println("even: \{i}")
      continue i + 1, acc + i
    }
  } nobreak {
    acc
  }
  println(sum)
}
```



输出

```
even: 2
even: 4
even: 6
12
```



### `for .. in` 循环

MoonBit 支持通过 `for .. in` 循环语法遍历不同数据结构和序列的元素：

```
for x in [1, 2, 3] {
  println(x)
}
```



`for .. in` 循环被转换为在 MoonBit 标准库中使用 `Iter`。任何具有方法 `.iter() : Iter[T]` 的类型都可以使用 `for .. in` 进行遍历。有关 `Iter` 类型的更多信息，请参见下面的 [迭代器](https://docs.moonbitlang.cn/language/fundamentals.html#iterator)。

循环绑定可以使用穷尽模式，因此可以直接在循环头中解构元素。模式必须能匹配所有可能的元素；像 `Some(value)` 这样可反驳的情况应在循环体内处理。

```
test "destructuring patterns in for-in loops" {
  let mut total = 0
  for (x, y) in [(1, 2), (3, 4)] {
    total += x + y
  }
  assert_eq(total, 10)
}
```



`for .. in` 循环还支持遍历整数序列，例如：

```
test {
  let mut i = 0
  for j in 0..<10 {
    i += j
  }
  assert_eq(i, 45)
  let mut k = 0
  for l in 0..<=10 {
    k += l
  }
  assert_eq(k, 55)
}
```



除了单个值的序列外，MoonBit 还支持通过 MoonBit 标准库中的 `Iter2` 类型遍历两个值的序列，例如 `Map`。任何具有方法 `.iter2() : Iter2[A, B]` 的类型都可以使用两个循环变量的 `for .. in` 进行遍历：

```
for k, v in { "x": 1, "y": 2, "z": 3 } {
  println(k)
  println(v)
}
```



另一个使用两个循环变量的 `for .. in` 的示例是在遍历数组时跟踪数组索引：

```
fn main {
  for index, elem in [4, 5, 6] {
    let i = index + 1
    println("The \{i}-th element of the array is \{elem}")
  }
}
```



输出

```
The 1-th element of the array is 4
The 2-th element of the array is 5
The 3-th element of the array is 6
```



`for .. in` 循环的主体支持诸如 `return`、`break` 和错误处理等控制流操作：

```
fn main {
  let map = { "x": 1, "y": 2, "z": 3, "w": 4 }
  for k, v in map {
    if k == "y" {
      continue
    }
    println("\{k}, \{v}")
    if k == "z" {
      break
    }
  }
}
```



输出

```
x, 1
z, 3
```



如果循环变量未使用，可以使用 `_` 忽略它。

### 范围表达式与 `for .. in` 循环

`for .. in` 循环还能和范围表达式配合，用于遍历整数区间：

```
fn main {
  for x in 0..<5 {
    println(x)
  }
}
```



输出

```
0
1
2
3
4
```



`for .. in` 循环中一共有四种可用的范围表达式：

- `a..<b`：升序地从 `a` 遍历到 `b`（不包含 `b`）
- `a..<=b`：升序地从 `a` 遍历到 `b`（包含 `b`）
- `a>..b`：降序地从 `a` 遍历到 `b`（不包含 `a`）
- `a>=..b`：降序地从 `a` 遍历到 `b`（包含 `a`）

### 列表推导式

MoonBit 支持列表推导式语法，可以通过遍历另一个集合或范围来构造集合：

```
let squares = [ for x in 1..<=5 => x * x ]
let even_numbers = [ for x in 0..<100 if x % 2 == 0 => x ]
let labelled = [ for i, x in ["a", "b", "c"] => "\{i}: \{x}" ]
let map = { 1: 2, 2: 4, 3: 8 }
let present = [ for x in [1, 2, 3] if map.get(x) is Some(y) => y ]
```



语法是 `[ for ... => ... ]`。`=>` 之前的部分遵循与 `for .. in` 相同的迭代规则：一个绑定变量使用 `Iter`，两个绑定变量使用 `Iter2`，并且支持 `0..<10` 这样的范围表达式。可选的 `if` 守卫会在求值结果表达式之前筛选元素。守卫中的 `is` 表达式引入的名称，例如上面的 `y`，可以在结果表达式中使用。

如果没有期望类型，结果默认是 `Array[T]`。如果期望类型已知，列表推导式也可以构造 `FixedArray[T]`、`ReadOnlyArray[T]`、`String`、`Bytes` 或 `Json`：

```
let text : String = [ for x in 0..<3 => (x + 'a').unsafe_to_char() ]
let bytes : Bytes = [ for x in 0..<3 => x.to_byte() ]
let fixed : FixedArray[_] = [ for x in 1..<=3 => x ]
```



对于惰性或无穷序列，请直接创建 `Iter[T]`。下面的迭代器在捕获的变量中保存斐波那契状态，并在收集前限制长度：

```
let mut p1 = 1
let mut p2 = 0
let fib_numbers : Iter[Int32] = Iter::new(fn() {
  let next = p1
  p1 = p1 + p2
  p2 = next
  Some(next)
})
let first_six = fib_numbers.take(6).collect()
```



列表推导式内部不允许使用 `return`、`break` 和 `continue` 等控制流操作。

### 带标记的 Continue/Break

当一个循环被标记的时候，它可以从循环中的 `break` 或者 `continue` 中引用，例如：

循环一旦带有标签，直接指向该循环的 `break` 或 `continue` 也应使用该标签。带标签循环内部直接出现的不带标签 `break` 或 `continue` 已弃用，因为其目标不够明确。

```
test "break label" {
  let mut count = 0
  let xs = [1, 2, 3]
  let ys = [4, 5, 6]
  let res = outer~: for i in xs {
    for j in ys {
      count = count + i
      break outer~ j
    }
  } nobreak {
    -1
  }
  assert_eq(res, 4)
  assert_eq(count, 1)
}

test "continue label" {
  let mut count = 0
  let init = 10
  let res = outer~: for i = init {
    if i == 0 {
      break outer~ 42
    }
    for ;; {
      count = count + 1
      continue outer~ i - 1
    }
  }
  assert_eq(res, 42)
  assert_eq(count, 10)
}
```



### 带标签的代码块

代码块也可以带标签。`break label~ value` 会立即退出代码块，并使 `value` 成为代码块的结果。这适合从嵌套控制流中提前退出，同时不返回外围函数。

```
fn absolute(n : Int32) -> Int32 {
  result~: {
    if n < 0 {
      break result~ -n
    }
    n
  }
}
```



未带标签的 `break` 不能退出或越过带标签的代码块；`continue` 只能指向带标签的循环，不能指向带标签的代码块。

代码块标签和循环标签共享同一个命名空间。在嵌套的代码块或循环上重复使用外层标签会遮蔽该外层标签，并产生 [E0036](https://docs.moonbitlang.cn/language/error_codes/E0036.html)。请使用不同的名称，确保每个带标签的 `break` 或 `continue` 都有明确的目标。

### `defer` 和 `errdefer` 表达式

`defer` 表达式可以实现可靠的资源释放。`defer` 的语法如下

```
defer <expr>
<body>
```



当程序离开 `body` 时，`expr` 里的内容会被执行。例如，下面的程序：

```
  defer println("释放资源")
  println("使用资源")
```



会先输出 `使用资源`，然后输出 `释放资源`。无论 `body` 以何种方式退出，`defer` 表达式都会被执行。`defer` 能够处理 [错误](https://docs.moonbitlang.cn/language/error-handling.html)，以及 `return`/`break`/`continue` 等控制流构造。

连续的 `defer` 会以倒序执行。例如，下面的程序：

```
  defer println("第一处 defer")
  defer println("第二处 defer")
  println("做些事情")
```



会先输出 `做些事情`，然后输出 `第二处 defer`，最后输出 `第一处 defer`

`defer` 的右侧不允许使用 `return`、`break` 和 `continue`。除此之外，清理表达式可以抛出错误，并且在异步代码中执行异步操作。如果清理表达式抛出错误，该错误会替换任何导致主体退出的错误。以下测试确认清理错误会替换主体错误：

```
  let message = try {
    defer {
      raise Failure("cleanup error")
    }
    raise Failure("body error")
  } catch {
    Failure(message) => message
  }
  assert_eq(message, "cleanup error")
```



`errdefer` 的一般形式与 `defer` 相同，但仅当主体抛出错误或异步代码被取消时，才执行清理表达式：

```
errdefer <expr>
<body>
```



正常结束或通过 `return`、`break`、`continue` 离开时，清理不会执行。与 `defer` 一样，其清理表达式可以抛出错误，并且在异步代码中执行异步操作。如果清理表达式抛出错误，该错误会成为最终结果，并替换触发 `errdefer` 的错误（如果有）。

它适合在不处理原始错误的情况下回滚部分完成的操作：

```
fn operation_that_may_fail() -> Unit raise {
  fail("operation failed")
}

test "errdefer" {
  let mut cleaned_up = false
  try {
    errdefer {
      cleaned_up = true
    }
    operation_that_may_fail()
  } catch {
    _ => ()
  }
  assert_true(cleaned_up)
}
```



`errdefer` 特别适合用于返回资源的函数：

```
  async fn connect(addr : Addr) -> Tcp {
    let sock = make_tcp_socket()
    errdefer sock.close()
    connect_tcp_socket(sock, addr)
    sock
  }
```



如果 `connect_tcp_socket` 成功，`sock` 会返回给调用方，此时不得关闭它。如果连接失败或被取消，`sock` 不会被返回，必须将其关闭以避免资源泄漏。因此这里使用 `errdefer` 而不是 `defer`。

如果主体不可能抛出错误，`errdefer` 就永远不会执行，并产生 [E0091](https://docs.moonbitlang.cn/language/error_codes/E0091.html)。如果兜底处理器只进行清理并重新抛出同一个错误，通常应改用 `errdefer`；参见 [E0092](https://docs.moonbitlang.cn/language/error_codes/E0092.html)。

## 迭代器

迭代器是一个对象，它在遍历序列的同时提供对其元素的访问。传统的面向对象语言如 Java 的 `Iterator<T>` 使用 `next()` 和`hasNext()` 来遍历迭代过程，而函数式语言（JavaScript 的 `forEach`，Lisp 的 `mapcar`）提供了一个高阶函数，该函数接受一个操作和一个序列，然后使用该操作应用于序列。前者称为外部迭代器（对用户可见），后者称为内部迭代器（对用户不可见）。

内置类型 `Iter[T]` 是 MoonBit 的外部迭代器实现。它提供 `next()` 来拉取下一个值：返回 `Some(value)` 并推进迭代器，或在迭代结束时返回 `None`。几乎所有内置的顺序数据结构都已经实现了 `Iter`：

```
///|
fn filter_even(l : Array[Int32]) -> Array[Int32] {
  let l_iter : Iter[Int32] = l.iter()
  l_iter.filter(x => (x & 1) == 0).collect()
}

///|
fn fact(n : Int32) -> Int32 {
  let start = 1
  let range : Iter[Int32] = start.until(n)
  range.fold(Int32::mul, init=start)
}
```



常用的方法包括：

- `each`: 遍历迭代器中的每个元素，对每个元素应用某个函数。
- `fold`: 使用给定的函数，从给定的初始值开始，对迭代器的元素进行“折叠”。
- `collect`: 将迭代器的元素收集到一个数组中。
- `filter`: （惰性）根据谓词函数过滤迭代器的元素。
- `map`: （惰性）使用映射函数转换迭代器的元素。
- `concat`: （惰性）通过将第二个迭代器的元素附加到第一个迭代器，将两个迭代器合并为一个。

像 `filter` 和 `map` 这样的方法在序列对象（例如 Array）上非常常见。但是，`Iter` 的不同之处在于，任何构造新 `Iter` 的方法都是**惰性**的（即在调用时不会开始迭代，因为它被包装在一个函数内），因此不会为中间值分配内存。这就是使 `Iter` 优于遍历序列的原因：没有额外的成本。MoonBit 鼓励用户将 `Iter` 传递给函数，而不是传递序列对象本身。

预定义的序列结构如 `Array` 及其迭代器应该足够使用。但是，为了在自定义序列（元素类型为 `S`）中使用这些方法，我们需要实现 `Iter`，即返回 `Iter[S]` 的函数。以 `Bytes` 为例：

```
///|
fn iter(data : Bytes) -> Iter[Byte] {
  let mut index = 0
  Iter::new(fn() -> Byte? {
    if index < data.length() {
      let byte = data[index]
      index += 1
      Some(byte)
    } else {
      None
    }
  })
}
```



迭代器是单次遍历的：一旦调用 `next()` 或使用 `each`、`fold`、`collect` 等方法消耗它们，其内部状态就会推进，无法重置。如果需要再次遍历序列，请从源头重新获取一个 `Iter`。

使用 `[| ... |]` 显式构造 `Iter`。分隔符内支持元素、展开语法和推导式：

```
  let prefix = [| 1, 2, 3 |]
  let values = [| ..prefix, 4, 5 |]
  let squares = [| for x in 1..<=3 => x * x |]
```



在 `[| x, y |]` 中，`x` 和 `y` 会在构造迭代器字面量时求值。对于 `..xs`，`xs` 本身会立即求值，但消费所得迭代器仍是惰性的。推导式 `[| for ... |]` 完全惰性，只在外层迭代器被消费时运行。

不再建议根据期望类型，用 `[x, ..xs]` 这类重载数组字面量构造 `Iter`，因为类型会隐式改变求值顺序。请改用 `[| x, ..xs |]`。

## 自定义数据类型

创建新数据类型有两种方法：`struct` 和 `enum`。

### 结构体

在 MoonBit 中，结构体类似于元组，但其字段通过字段名索引。结构体可使用 `T::{ field: value }` 这样的带类型限定结构体字面量构造。即使仅凭字段就足以推断类型，类型前缀仍能明确所构造的类型。字段可通过点语法 `s.f` 访问。若字段使用关键字 `mut` 标记为可变，则可以为其赋新值。

```
struct User {
  id : Int32
  name : String
  mut email : String
}
```



```
fn main {
  let u = User::{ id: 0, name: "John Doe", email: "john@doe.com" }
  u.email = "john@doe.name"
  //! u.id = 10
  println(u.id)
  println(u.name)
  println(u.email)
}
```



输出

```
0
John Doe
john@doe.name
```



#### 使用简写构造结构体

如果已经有一些变量，如 `name` 和 `email`，在构造结构体时重复这些名称是多余的。可以使用简写，它的行为完全相同：

```
let name = "john"
let email = "john@doe.com"
let u = User::{ id: 0, name, email }
```



上下文能够确定类型时，未限定的结构体字面量仍可被推断。直接使用 `let` 绑定时，即使没有其他结构体拥有相同字段，也建议保留类型前缀：

```
let u2 = User::{ id: 0, name, email }
```



#### 结构体更新语法

可以用这个语法来根据现有结构体创建一个新的结构体，但只更新部分字段。

```
fn main {
  let user = User::{ id: 0, name: "John Doe", email: "john@doe.com" }
  let updated_user = User::{ ..user, email: "john@doe.name" }
  println(
    (
      $|{ id: \{user.id}, name: \{user.name}, email: \{user.email} }
      $|{ id: \{updated_user.id}, name: \{updated_user.name}, email: \{updated_user.email} }
    ),
  )
}
```



输出

```
{ id: 0, name: John Doe, email: john@doe.com }
{ id: 0, name: John Doe, email: john@doe.name }
```



#### 自定义构造器

MoonBit 支持为任意类型定义自定义构造器。构造器是一种特殊方法，其名称与返回类型相同。下面先从结构体示例开始：

```
struct IntBox {
  value : Int32
} derive(Debug)

pub extend IntBox with Debug::{to_repr}
```



随后应将构造器实现为一个与结构体类型同名的方法。其返回值必须是该结构体本身：

```
fn IntBox::IntBox(value : Int32) -> IntBox {
  { value, }
}
```



当一个结构体定义了构造器，它就可以直接通过类型名字被构造：

```
  let box = IntBox(10)
  debug_inspect(box, content="{ value: 10 }")
```



构造器调用遵循构造器方法的签名，因此无标签参数可以写成熟悉的 `TypeName(value)` 形式。

构造器也可以像普通函数一样使用带标签参数和可选参数：

```
struct StructWithConstr {
  x : Int32
  y : Int32
} derive(Debug)

pub extend StructWithConstr with Debug::{to_repr}
```



```
fn StructWithConstr::StructWithConstr(x~ : Int32, y~ : Int32 = x) -> StructWithConstr {
  { x, y }
}
```



```
  let s = StructWithConstr(x=1)
  debug_inspect(s, content="{ x: 1, y: 1 }")
```



由于结构体构造器由普通函数实现，因此它们也可以抛出错误：

```
suberror BuildError {
  NegativeInput
} derive(Debug)

pub extend BuildError with Debug::{to_repr}

struct Positive {
  value : Int32
} derive(Debug)

pub extend Positive with Debug::{to_repr}
```



```
fn Positive::Positive(x : Int32) -> Positive raise BuildError {
  guard x >= 0 else { raise NegativeInput }
  { value: x }
}
```



```
  try Positive(10) catch {
    error => debug_inspect(error, content="NegativeInput")
  } noraise {
    value => debug_inspect(value, content="{ value: 10 }")
  }
  try Positive(-1) catch {
    error => debug_inspect(error, content="NegativeInput")
  } noraise {
    value => debug_inspect(value, content="{ value: -1 }")
  }
```



其他类型也可以使用同样的 `fn Type::Type(...) -> Type` 形式。自定义构造器不能与该类型已有的构造器同名：

```
enum Endpoint {
  Host(String, Int32)
} derive(Debug)

pub extend Endpoint with Debug::{to_repr}

fn Endpoint::Endpoint(host : String, port~ : Int32 = 80) -> Endpoint {
  Host(host, port)
}

test {
  let endpoint = Endpoint("example.com", port=443)
  debug_inspect(endpoint, content="Host(\"example.com\", 443)")
}
```



异步构造器使用 `async fn TypeName::TypeName` 声明，并且可以在异步代码中使用：

```
struct AsyncBox {
  value : Int32
} derive(Debug)

///|
pub extend AsyncBox with Debug::{to_repr}
```



```
async fn AsyncBox::AsyncBox(x : Int32) -> AsyncBox {
  @async.sleep(0)
  { value: x }
}
```



```
async test "struct constructor async" {
  let box = AsyncBox(10)
  debug_inspect(box, content="{ value: 10 }")
}
```



通过自定义构造器创建值与[枚举构造器](https://docs.moonbitlang.cn/language/fundamentals.html#enum)具有相同的调用语义，但自定义构造器不能用于模式匹配。例如，通过构造器创建外部包中的 `struct` 时，如果表达式的期望类型已知，就可以省略包名。

自定义构造器由普通函数实现，因此可以[抛出错误](https://docs.moonbitlang.cn/language/error-handling.html)或[执行异步操作](https://docs.moonbitlang.cn/language/async-experimental.html)，也支持[可选参数](https://docs.moonbitlang.cn/language/fundamentals.html#optional-arguments)。可选参数的默认值写在构造器实现上，与普通函数签名相同。

### 枚举

枚举类型类似于函数式语言中的代数数据类型。熟悉 C/C++ 的用户可能更喜欢称其为标记联合。

枚举可以有一组情况（构造函数）。构造函数的名称必须以大写字母开头。可以使用这些名称来构造枚举的相应情况，或在模式匹配中检查枚举值属于哪个分支：

```
/// 一个枚举类型，表示两个值之间的顺序关系，
/// 有三种情况 "Smaller"、"Greater" 和 "Equal"
enum Relation {
  Smaller
  Greater
  Equal
}
```



```
/// 比较两个整数之间的顺序关系
fn compare_int(x : Int32, y : Int32) -> Relation {
  if x < y {
    // 当创建一个枚举时，如果目标类型已知，
    // 可以直接写构造函数名称
    Smaller
  } else if x > y {
    // 但是当目标类型未知时，
    // 你总是可以使用 `TypeName::Constructor` 来创建一个枚举
    Relation::Greater
  } else {
    Equal
  }
}

/// 输出一个类型为 `Relation` 的值
fn print_relation(r : Relation) -> Unit {
  // 使用模式匹配来决定 `r` 属于哪种情况
  match r {
    // 在模式匹配期间，如果类型已知，
    // 写构造函数的名称就足够了
    Smaller => println("smaller!")
    // 但是你也可以在模式匹配中使用 `TypeName::Constructor` 语法
    Relation::Greater => println("greater!")
    Equal => println("equal!")
  }
}
```



```
fn main {
  print_relation(compare_int(0, 1))
  print_relation(compare_int(1, 1))
  print_relation(compare_int(2, 1))
}
```



输出

```
smaller!
equal!
greater!
```



枚举情况也可以携带额外数据。以下是使用枚举定义整数列表类型的示例：

```
enum Lst {
  Nil
  // 构造函数 `Cons` 携带额外的数据：列表的第一个元素，
  // 和列表的其余部分
  Cons(Int32, Lst)
}
```



```
// 除了将额外数据绑定到变量之外，
// 你还可以继续匹配构造函数内部的额外数据。
// 以下是一个函数，用于判断列表是否只包含一个元素
fn is_singleton(l : Lst) -> Bool {
  match l {
    // 此分支仅匹配形状为 `Cons(_, Nil)` 的值，
    // 即长度为 1 的列表
    Cons(_, Nil) => true
    // 使用 `_` 匹配其他所有情况
    _ => false
  }
}

fn print_list(l : Lst) -> Unit {
  // 在模式匹配带有额外数据的枚举时，
  // 除了决定值属于哪种情况
  // 你还可以提取该情况内部的额外数据
  match l {
    Nil => println("nil")
    // 这里 `x` 和 `xs` 定义了新变量
    // 而不是引用现有变量，
    // 如果 `l` 是一个 `Cons`，那么 `Cons` 的额外数据
    // （第一个元素和列表的其余部分）
    // 将绑定到 `x` 和 `xs
    Cons(x, xs) => {
      println("\{x},")
      print_list(xs)
    }
  }
}
```



```
fn main {
  // 使用 `Cons` 创建值时，必须提供 `Cons` 的额外数据
  let l : Lst = Cons(1, Cons(2, Nil))
  println(is_singleton(l))
  print_list(l)
}
```



输出

```
false
1,
2,
nil
```



#### 非穷尽枚举

当库的后续版本可能添加构造器时，可以用 [`#non_exhaustive`](https://docs.moonbitlang.cn/language/attributes.html#non-exhaustive-enum-attribute) 标记枚举。下游的模式匹配必须覆盖当前已知的构造器，然后使用 `Type::..` 处理库未来版本新增的构造器。

#### 构造器与带标签参数

枚举构造器可以有带标签的参数：

```
enum E {
  // `x` 和 `y` 是有标签参数
  C(x~ : Int32, y~ : Int32)
}
```



```
// 使用有标签参数的构造函数进行模式匹配
fn f(e : E) -> Unit {
  match e {
    // `label=pattern`
    C(x=0, y=0) => println("0!")
    // `x~` 是 `x=x` 的缩写
    // 未匹配的有标签参数可以通过 `..` 省略
    C(x~, ..) => println(x)
  }
}
```



```
fn main {
  f(C(x=0, y=0))
  let x = 0
  f(C(x~, y=1)) // <=> C(x=x, y=1)
}
```



输出

```
0!
0
```



也可以像在模式匹配中访问结构体字段一样访问构造函数的有标签参数：

```
enum Object {
  Point(x~ : Double, y~ : Double)
  Circle(x~ : Double, y~ : Double, radius~ : Double)
}

suberror NotImplementedError derive(Debug)

pub extend NotImplementedError with Debug::{to_repr}

fn Object::distance_with(
  self : Object,
  other : Object,
) -> Double raise NotImplementedError {
  match (self, other) {
    // For variables defined via `Point(..) as p`,
    // the compiler knows it must be of constructor `Point`,
    // so you can access fields of `Point` directly via `p.x`, `p.y` etc.
    (Point(_) as p1, Point(_) as p2) => {
      let dx = p2.x - p1.x
      let dy = p2.y - p1.y
      (dx * dx + dy * dy).sqrt()
    }
    (Point(_), Circle(_)) | (Circle(_), Point(_)) | (Circle(_), Circle(_)) =>
      raise NotImplementedError
  }
}
```



```
fn main {
  let p1 : Object = Point(x=0, y=0)
  let p2 : Object = Point(x=3, y=4)
  let c1 : Object = Circle(x=0, y=0, radius=2)
  try {
    println(p1.distance_with(p2))
    println(p1.distance_with(c1))
  } catch {
    _ => println("NotImplementedError")
  }
}
```



输出

```
5
NotImplementedError
```



#### 构造器与可变字段

也可以为构造器定义可变字段。这对于定义命令式数据结构特别有用：

```
// 使用可变二叉搜索树实现的集合。
struct Set[X] {
  mut root : Tree[X]
}

fn[X : Compare] Set::insert(self : Set[X], x : X) -> Unit {
  self.root = self.root.insert(x, parent=Nil)
}

// 带有亲指针的可变二叉搜索树
enum Tree[X] {
  Nil
  // 只有带标签的参数可以是可变的
  Node(
    mut value~ : X,
    mut left~ : Tree[X],
    mut right~ : Tree[X],
    mut parent~ : Tree[X]
  )
}

// 将一个新元素插入到二叉搜索树中。
// 返回新的树
fn[X : Compare] Tree::insert(
  self : Tree[X],
  x : X,
  parent~ : Tree[X],
) -> Tree[X] {
  match self {
    Nil => Node(value=x, left=Nil, right=Nil, parent~)
    Node(_) as node => {
      let order = x.compare(node.value)
      if order == 0 {
        // 修改构造器的字段
        node.value = x
      } else if order < 0 {
        // 在这里创建的 `node` 和 `node.left` 之间的循环
        node.left = node.left.insert(x, parent=node)
      } else {
        node.right = node.right.insert(x, parent=node)
      }
      // 树不为空，所以新的树就是原来的树
      node
    }
  }
}
```



#### 可扩展枚举

`extenum` 定义的是开放的枚举类型。与普通的 `enum` 不同，`extenum` 之后可以继续接收更多构造器，包括来自其他包的构造器。当某个包想定义共享的事件、消息或扩展点类型，而其他包贡献各自的分支时，这会很有用。

```
pub extenum LogEvent[T]
```



该声明只定义类型，不包含构造器。通过 `extenum Type += { ... }` 添加初始构造器；扩展上的可见性决定这些构造器的可见性：

```
pub(all) extenum LogEvent[T] += {
  Info(T)
}
```



同一个包之后还可以继续添加更多构造器：

```
pub(all) extenum LogEvent[T] += {
  Warning(T)
  Critical(T, T)
}
```



要从另一个包扩展可扩展枚举，原始类型声明必须使用 `pub`。目标类型还需要由定义它的包限定：

```
pub(all) extenum @base.LogEvent[T] += {
  Debug(T)
}
```



可扩展枚举的构造器由定义该构造器的包来限定。对于来自当前包的构造器，当预期类型已知时，可以直接使用构造器名称。对于来自其他包的构造器，在表达式和模式中使用 `@pkg.Constructor`。当你想同时显式写出可扩展枚举类型和构造器来源时，可以将构造器写成 `@type_pkg.Type::@constructor_pkg.Constructor`。

当一个包同时导入基础包和扩展包时，来自这两个包的值具有同一个可扩展枚举类型：

```
pub fn describe(event : @base.LogEvent[String]) -> String {
  match event {
    @base.Info(message) => "info: \{message}"
    @base.Warning(message) => "warning: \{message}"
    @base.Critical(code, message) => "critical \{code}: \{message}"
    @plugin.Debug(message) => "debug: \{message}"
    _ => "unknown"
  }
}

pub fn debug_event(message : String) -> @base.LogEvent[String] {
  @plugin.Debug(message)
}

pub fn qualified_debug_event(message : String) -> @base.LogEvent[String] {
  @base.LogEvent::@plugin.Debug(message)
}
```



模式匹配必须包含通配符分支，因为当前声明之外还可以继续添加更多构造器。

只有 `extenum` 声明可以被扩展。普通的 `enum` 声明是封闭的。如果不希望下游包添加构造器，请使用普通 `enum`；私有或只读的 `extenum` 声明已被弃用。

### 元组结构体

MoonBit 支持一种特殊的结构体称为元组结构体：

```
struct UserId(Int32)

struct UserInfo(UserId, String)
```



元组结构体类似于只有一个构造函数的枚举（与元组结构体本身的名称相同）。因此，可以使用构造函数创建或使用模式匹配提取底层表示：

```
fn main {
  let id : UserId = UserId(1)
  let name : UserInfo = UserInfo(id, "John Doe")
  let UserId(uid) = id // uid : Int32
  let UserInfo(_, uname) = name // uname: String
  println(uid)
  println(uname)
}
```



输出

```
1
John Doe
```



除了模式匹配之外，还可以使用索引访问元素，类似于元组：

```
fn main {
  let id : UserId = UserId(1)
  let info : UserInfo = UserInfo(id, "John Doe")
  let uid : Int32 = id.0
  let uname : String = info.1
  println(uid)
  println(uname)
}
```



输出

```
1
John Doe
```



### 类型别名

MoonBit 支持使用语法 `type NewType = OldType` 定义类型别名：

```
pub type Index = Int32
pub type MyIndex = Int32
pub type MyMap = Map[Int32, String]
```



与上面所有其他类型声明不同，类型别名不定义新类型，它只是一个行为与其定义完全相同的类型宏。因此，例如，不能为类型别名定义新方法或实现特征。

小技巧

类型别名可用于执行增量代码重构。

例如，如果要将类型 `T` 从 `@pkgA` 移动到 `@pkgB`，可以在 `@pkgA` 中留下一个类型别名 `type T = @pkgB.T`，

## 模式匹配

模式匹配允许我们匹配特定模式并从数据结构中绑定数据。

### 简单模式

我们可以将表达式与以下内容进行模式匹配：

- 字面量，例如布尔值、数字、字符、字符串等
- 常量
- 结构体
- 枚举
- 数组
- 键值对
- JSON

等等。我们可以定义标识符来绑定匹配的值，以便稍后使用。

```
const ONE = 1

fn match_int(x : Int32) -> Unit {
  match x {
    0 => println("zero")
    ONE => println("one")
    value => println(value)
  }
}
```



我们可以使用 `_` 作为我们不关心的值的通配符，并使用 `..` 忽略结构体或枚举的剩余字段，或数组（参见 [数组模式](https://docs.moonbitlang.cn/language/fundamentals.html#array-pattern)）。

```
struct Point3D {
  x : Int32
  y : Int32
  z : Int32
}

fn match_point3D(p : Point3D) -> Unit {
  match p {
    { x: 0, .. } => println("on yz-plane")
    _ => println("not on yz-plane")
  }
}

enum Point[T] {
  Point2D(Int32, Int32, name~ : String, payload~ : T)
}

fn[T] match_point(p : Point[T]) -> Unit {
  match p {
    //! Point2D(0, 0) => println("2D origin")
    Point2D(0, 0, ..) => println("2D origin")
    Point2D(_) => println("2D point")
    _ => panic()
  }
}
```



我们可以使用 `as` 为某些模式命名，可以使用 `|` 一次匹配多个情况。在单个模式中，变量名只能绑定一次，并且在 `|` 模式的两侧应绑定相同的变量集。

```
match expr {
  //! Add(e1, e2) | Lit(e1) => ...
  Lit(n) as a => ...
  Add(e1, e2) | Mul(e1, e2) => ...
  ...
}
```



### 数组模式

数组模式可以用来匹配以下类型以获取其对应的元素或视图（View）：

| 类型                                  | 元素 | 视图         |
| ------------------------------------- | ---- | ------------ |
| Array[T], ArrayView[T], FixedArray[T] | T    | ArrayView[T] |
| Bytes, BytesView                      | 字节 | BytesView    |
| String, StringView                    | 字符 | StringView   |

数组模式可以有以下形式：

- `[]`：匹配空数组
- `[pa, pb, pc]`：匹配长度为 3 的数组，并将其中的元素分别绑定到 `pa`, `pb`, `pc`
- `[pa, ..rest, pb]`：匹配至少有两个元素的数组，并将第一个元素绑定到`pa`，最后一个元素绑定到 `pb`，其余元素绑定到 `rest`。如果不需要其余元素，可以省略绑定 `rest`。在 `..` 部分前后允许任意数量的元素。由于 `..` 可以匹配不确定数量的元素，因此在数组模式中最多只能出现一次。

```
test {
  let ary = [1, 2, 3, 4]
  if ary is [a, b, .. rest] && a == 1 && b == 2 && rest.length() == 2 {
    inspect("a = \{a}, b = \{b}", content="a = 1, b = 2")
  } else {
    fail("")
  }
  guard ary is [.., a, b] else { fail("") }
  inspect("a = \{a}, b = \{b}", content="a = 3, b = 4")
}
```



数组模式提供了一种 Unicode 安全的方式来操作字符串，这意味着它在访问元素的时候不会跨越代码单元边界。例如，我们可以检查一个包含 Unicode 的字符串是否是回文：

```
test {
  fn palindrome(s : String) -> Bool {
    for view = s.view() {
      match view {
        [] | [_] => break true
        [a, .. rest, b] => if a == b { continue rest } else { break false }
      }
    }
  }

  inspect(palindrome("abba"), content="true")
  inspect(palindrome("中b中"), content="true")
  inspect(palindrome("文bb中"), content="false")
}
```



当数组模式中有连续的字符或字节常量时，可以使用模式展开 `..` 运算符将它们组合起来，使代码看起来更整洁。在这种情况下，`..` 后跟字符串或字节常量匹配确切数量的元素，因此它可以在数组模式中多次使用。

```
const NO : Bytes = b"no"

test {
  fn match_string(s : String) -> Bool {
    match s {
      [.. "yes", ..] => true // equivalent to ['y', 'e', 's', ..]
    }
  }

  fn match_bytes(b : Bytes) -> Bool {
    match b {
      [.. NO, ..] => false // equivalent to ['n', 'o', ..]
    }
  }
}
```



### 位串模式

位串模式可用于匹配字节容器中的打包比特字段。它们支持 `BytesView`、`Bytes`、`Array[Byte]`、`FixedArray[Byte]`、`ReadOnlyArray[Byte]` 和 `ArrayView[Byte]`。使用带 `be`/`le` 后缀的显式位宽以明确端序。`be` 支持 1..64 位；`le` 仅支持按字节对齐的宽度（8 * n），因为小端只对字节序有明确意义。没有 `..` 时，模式必须消费整个视图。

```
test {
  let packet : Bytes = b"\xD2\x10\x7F"
  let header : BytesView = packet[0:2]
  let (flag, kind, version, length) = match header {
    [u1be(flag), u3be(kind), u4be(version), u8be(length)] =>
      (flag, kind, version, length)
    _ => fail("bad header")
  }
  assert_eq(flag, 1)
  assert_eq(kind, 0b101)
  assert_eq(version, 0b0010)
  assert_eq(length, 16)
}
```



使用字面量位模式验证头部，并用 `..` 捕获剩余数据以供下一步解析。

```
test {
  let data : Bytes = b"\xF1\xAA\xBB"
  let view : BytesView = data[0:]
  let tag = match view {
    [u4be(0b1111), u4be(tag), .. rest] => {
      assert_eq(rest, b"\xAA\xBB"[0:])
      tag
    }
    _ => fail("bad prefix")
  }
  assert_eq(tag, 0b0001)
}
```



常见字节容器示例（注意 `MutArrayView` 需要切片）：

```
test {
  let b : Bytes = b"\x80"
  guard b is [u1be(1), ..] else { fail("Bytes") }

  let a : Array[Byte] = [b'\x80']
  guard a is [u1be(1), ..] else { fail("Array[Byte]") }

  let f : FixedArray[Byte] = [b'\x80']
  guard f is [u1be(1), ..] else { fail("FixedArray[Byte]") }

  let r : ReadOnlyArray[Byte] = [b'\x80']
  guard r is [u1be(1), ..] else { fail("ReadOnlyArray[Byte]") }

  let v : ArrayView[Byte] = a[:]
  guard v is [u1be(1), ..] else { fail("ArrayView[Byte]") }

  let mv : MutArrayView[Byte] = a.mut_view()
  guard mv[:] is [u1be(1), ..] else { fail("MutArrayView[Byte]") }
}
```



有符号模式使用二进制补码语义。例如，`u1be` 产生 `0` 或 `1`，而 `i1be` 产生 `0` 或 `-1`：

```
test {
  let bytes = b"\x80"
  let u : UInt32 = match bytes[:] {
    [u1be(u), ..] => u
    _ => fail("u1be")
  }
  let i : Int32 = match bytes[:] {
    [i1be(i), ..] => i
    _ => fail("i1be")
  }
  assert_eq(u, 1U)
  assert_eq(i, -1)
}
```



结果类型取决于位宽：

| 位宽                | 结果类型           |
| ------------------- | ------------------ |
| 1..32 位（`u`/`i`） | `UInt32` / `Int32` |
| 33..64 位（`u`）    | `UInt64`           |
| 33..64 位（`i`）    | `Int64`            |

在字节对齐的偏移处使用 `v128le(pattern)` 提取 128 位小端 SIMD 值。其载荷类型为 `V128`。

```
test {
  let bytes = b"\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F"
  let vector : V128 = match bytes {
    [v128le(value)] => value
    _ => fail("expected 16 bytes")
  }
  let _ = vector
}
```



备注

已知编译器问题：目前会在 native Windows 目标上跳过此示例，因为 C 后端的 `v128.load` 回退实现会发生递归。这并非 Windows 与 SSE2 不兼容。

### 范围模式

对于内置整数类型和 `Char`，MoonBit 允许匹配值是否落在特定范围内。

范围模式的形式为 `a..<b` 或 `a..<=b`，其中 `..<` 不包含上界，`..<=` 包含上界。旧的包含上界写法 `a..=b` 仍可使用，格式化后为 `a..<=b`。

降序范围模式 `a>..b` 和 `a>=..b` 也可使用，但会产生警告，建议改用等价的升序形式。

`a` 和 `b` 可以是以下之一：

- 字面量
- 使用 `const` 声明的常量
- `_`，表示此模式在此侧没有限制

以下是一些示例：

```
const Zero = 0

fn sign(x : Int32) -> Int32 {
  match x {
    _..<Zero => -1
    Zero => 0
    1..<_ => 1
  }
}

fn classify_char(c : Char) -> String {
  match c {
    'a'..<='z' => "lowercase"
    'A'..<='Z' => "uppercase"
    '0'..<='9' => "digit"
    _ => "other"
  }
}
```



### Map 模式

MoonBit 允许在类似 map 的数据结构上方便地进行匹配。在 map 模式内，`key : value` 语法将在 map 中存在 `key` 时匹配，并将 `key` 的值与模式 `value` 匹配。`key? : value` 语法将无论 `key` 是否存在都匹配，`value` 将与 `map[key]`（一个可选项）匹配。

```
match map {
  // 仅在 `map` 中存在 "b" 时匹配
  { "b": _, .. } => ...
  // 仅在 `map` 中不存在 "b" 且 "a" 存在于 `map` 时匹配。
  // 匹配时，将 `map` 中的 "a" 的值绑定到 `x`
  { "b"? : None, "a": x, .. } => ...
  // 编译器报告缺失的情况：{ "b"? : None, "a"? : None }
}
```



- 要使用 map 模式匹配数据类型 `T`，`T` 必须具有某种类型 `K` 和 `V` 的方法 `get(Self, K) -> Option[V]`（请参见 [方法和特征](https://docs.moonbitlang.cn/language/methods.html)）。
- 目前，map 模式的键部分必须是字面量或常量
- Map 模式始终是开放的：未匹配的键会被静默忽略，并且需要添加 `..` 以显示这一点
- Map 模式将编译为高效的代码：每个键最多只会被获取一次

### Json 模式

当匹配的值具有类型 `Json` 时，可以直接使用字面量模式，以及构造函数：

```
match json {
  { "version": "1.0.0", "import": [..] as imports, .. } => ...
  { "version": Number(i, ..), "import": Array(imports), .. } => ...
  ...
}
```



### or-pattern 中的默认绑定

or-pattern 的每个分支通常必须绑定完全相同的变量。可以在某个分支上使用 `with`，为该分支没有在结构上绑定的变量提供默认值：

```
fn option_value(value : Int32?) -> Int32 {
  match value {
    Some(x) | (None with x = 0) => x
  }
}

fn pair_value(value : (Int32, Int32)?) -> Int32 {
  match value {
    Some((x, y)) | (None with x = 0, y = 0) => x + y
  }
}

test {
  assert_eq(option_value(None), 0)
  assert_eq(option_value(Some(42)), 42)
  assert_eq(pair_value(None), 0)
  assert_eq(pair_value(Some((20, 22))), 42)
}
```



多个默认值写成 `(Pattern with x = value, y = value)`。括号能明确默认值属于哪个分支。默认值可以是在外围作用域中求值的通用表达式。默认表达式不能引用完整模式中的绑定变量，也不允许包含 `return`、`break`、`continue` 或 `raise` 等控制流。

### 守卫条件

模式匹配表达式中的每个分支都可以有一个守卫条件。守卫条件是一个布尔表达式，只有当该条件为真时，对应的分支才会被匹配。如果守卫条件为假，则跳过该分支并尝试下一个分支。例如：

```
fn guard_cond(x : Int32?) -> Int32 {
  fn f(x : Int32) -> Array[Int32] {
    [x, x + 42]
  }

  match x {
    Some(a) if f(a) is [0, b] => a + b
    Some(b) => b
    None => -1
  }
}

test {
  assert_eq(guard_cond(None), -1)
  assert_eq(guard_cond(Some(0)), 42)
  assert_eq(guard_cond(Some(1)), 1)
}
```



注意，在检查所有模式是否都被匹配表达式覆盖时，不会考虑守卫条件。因此，您会看到以下情况的警告：

```
fn guard_check(x : Int32?) -> Unit {
  match x {
    Some(a) if a >= 0 => ()
    Some(a) if a < 0 => ()
    None => ()
  }
}
```



警告

不鼓励在守卫条件中调用可能通过副作用改变被匹配的值的函数。在这种情况下，被改变的部分不会在后续模式中重新求值。请谨慎使用。

## 泛型

泛型在顶层函数和数据类型定义中受支持。可以在方括号内引入类型参数。我们可以重写上述数据类型 `List`，添加类型参数 `T` 以获得列表的通用版本。然后，我们可以定义列表上的通用函数，如 `map` 和 `reduce`。

```
///|
enum List[T] {
  Nil
  Cons(T, List[T])
}

///|
fn[S, T] List::map(self : List[S], f : (S) -> T) -> List[T] {
  match self {
    Nil => Nil
    Cons(x, xs) => Cons(f(x), xs.map(f))
  }
}

///|
fn[S, T] List::reduce(self : List[S], op : (T, S) -> T, init : T) -> T {
  match self {
    Nil => init
    Cons(x, xs) => xs.reduce(op, op(init, x))
  }
}
```



## 特殊语法

### 管道

MoonBit 提供了方便的管道语法 `x |> f(y)` 和 `f <| x`，可以用来串联常规函数调用，或让嵌套的构建器风格代码更易读：

```
5 |> ignore // <=> ignore(5)
[] |> Array::push(5) // <=> Array::push([], 5)
1
|> add(5) // <=> add(1, 5)
|> x => { x + 1 }
|> ignore // <=> ignore(add(1, 5) + 1)
```



MoonBit 代码遵循*数据优先*风格，也就是说，函数将它的“主题”放置在第一个参数的位置。所以，管道默认将左侧的值填入右侧的函数调用的第一个参数的位置。例如 `x |> f(y)`等价于`f(x,y)`。

你也可以使用`_`操作符改变`x`在函数`f`的调用中的插入位置，例如`x |> f(y, _)`, 这等价于`f(y,x)`。带标签的参数也是支持的。

管道操作符也可以连接到箭头函数。通过管道传入箭头函数时，函数体必须用花括号包裹，例如 `value |> x => { x + 1 }`。

反向管道运算符会把右侧表达式作为左侧调用的最后一个参数。例如，`f <| x` 等价于 `f(x)`，而 `f(a, b) <| c` 等价于 `f(a, b, c)`。这对于 DSL 风格的代码尤其有用，因为像 `div([text("hello")])` 这样的嵌套调用可以改写为 `div <| [text <| "hello"]`。

```
let page = div <| [
    text <| "hello",
    section("toolbar") <| fn() { [text <| "save", text <| "cancel"] },
  ]
inspect(
  page,
  content="div(text(hello), toolbar: div(text(save), text(cancel)))",
)
```



因为反向管道会附加最后一个参数，所以它也很适合最后一个参数是 lambda 的函数，从而可以写出类似 `section("toolbar") <| fn () { ... }` 这样的尾随 lambda 风格。

### 级联运算符

级联运算符`..`用于连续对同一值执行一系列可变操作。语法如下：

```
let arr = []..append([1])
```



这里 `x..f()` 等价于 `{ x.f(); x }`。

考虑以下情况：对于具有诸如`write_string`，`write_char`，`write_object`等方法的`StringBuilder`类型，我们经常需要对同一`StringBuilder`值执行一系列操作：

```
let builder = StringBuilder()
builder.write_char('a')
builder.write_char('a')
builder.write_object(1001)
builder.write_string("abcdef")
let result = builder.to_string()
```



为了避免重复输入`builder`，其方法通常设计为返回`self`本身，允许使用`.`运算符链接操作。为了区分不可变和可变操作，在 MoonBit 中，对于所有返回`Unit`的方法，可以使用级联运算符进行连续操作，而无需修改方法的返回类型。

```
let result = StringBuilder()
  ..write_char('a')
  ..write_char('a')
  ..write_object(1001)
  ..write_string("abcdef")
  .to_string()
```



### is 表达式

`is` 表达式测试值是否符合特定模式。它返回一个 `Bool` 值，并可以在期望布尔值的任何地方使用，例如：

```
fn[T] is_none(x : T?) -> Bool {
  x is None
}

fn start_with_lower_letter(s : String) -> Bool {
  s is ['a'..<='z', ..]
}
```



通过 `is` 表达式绑定的标识符可以在以下的上下文中使用：

1. 在与表达式（`&&`）中：左侧表达式中绑定的标识符可以在右侧表达式中使用

   ```
   fn f(x : Int32?) -> Bool {
     x is Some(v) && v >= 0
   }
   ```

   

2. 在 `if` 的第一个分支中：如果条件是一系列布尔表达式 `e1 && e2 && ...`，则可以在条件为真的分支中使用 `is` 表达式中绑定的标识符。

   ```
   fn g(x : Array[Int32?]) -> Unit {
     if x is [v, .. rest] && v is Some(i) && i is (0..<=10) {
       debug(v)
       println(i)
       debug(rest)
     }
   }
   ```

   

3. 在成功的 `guard` 或 `guard!` 条件之后的语句中：

   ```
   fn h(x : Int32?) -> Unit {
     guard! x is Some(v)
     println(v)
   }
   ```

   

4. 在 `while` 循环中的使用：

   ```
   fn i(x : Int32?) -> Unit {
     let mut m = x
     while m is Some(v) {
       println(v)
       m = None
     }
   }
   ```

   

`is` 表达式只能接受一个简单模式，如果你需要通过 `as` 把模式绑定到某个变量上，需要加括号。比如：

```
fn j(x : Int32) -> Int32? {
  Some(x)
}

fn init {
  guard! j(42) is (Some(a) as b)
  println(a)
  debug(b)
}
```



### 正则字面量表达式

`re"..."` 是一个正则字面量表达式，其类型为 `Regex`。

正则字面量是普通表达式，因此可以存入局部绑定、作为参数传递、用作默认参数值，也可以定义为常量：

```
let r : Regex = re"a(b+)"
const IDENT_START : Regex = re"[A-Za-z_]"
const IDENT : Regex = IDENT_START + re"[A-Za-z0-9_]*"
```



`Regex` 值也可以通过 `+` 组合成序列，通过 `|` 组合成备选。在需要正则常量表达式的地方，例如 [`=~`](https://docs.moonbitlang.cn/language/fundamentals.html#regex-match-expression)，可以直接引用由正则字面量定义的具名 `const`。

与普通字符串字面量不同，正则字面量中的反斜杠不需要二次转义。例如，应写 `re"/\*"`，而不是 `re"/\\*"`。

```
const REGEX_IDENT_START = re"[A-Za-z_]"

const REGEX_IDENT_CONT = re"[A-Za-z0-9_]*"

const REGEX_AB : Regex = re"a" + re"b"

fn regex_default_arg(re~ : Regex = re"abc") -> Bool {
  re.execute("zabc") is Some(_)
}

test {
  let regex : Regex = re"a(b+)"
  assert_true(regex.execute("abbb") is Some(_))
  assert_true(regex.execute("ac") is None)

  assert_true(REGEX_AB.execute("ab") is Some(_))
  assert_true(REGEX_AB.execute("ac") is None)
  assert_true(regex_default_arg())
}
```



非法的正则字面量会在编译期被拒绝。

正则字面量使用 MoonBit 的正则语法，支持的形式包括：

- 字面字符：普通字符匹配其自身
- 通配符：`.` 匹配任意单个字符，包括换行符
- 字符类：`[abc]`、`[^abc]`、`[a-z]`
- 字符类中的 POSIX 类：`[[:digit:]]`、`[[:alpha:]]`、`[[:space:]]`、`[[:word:]]`、`[[:xdigit:]]` 等
- 量词：`*`、`+`、`?`、`{n}`、`{n,}`、`{n,m}`
- 非贪婪量词：`*?`、`+?`、`??`、`{n}?`、`{n,}?`、`{n,m}?`
- 分组与分支：`( ... )`、`(?: ... )`、`(?<name> ... )`、`a|b`
- 断言：`^`、`$`、`\b`、`\B`
- 作用域修饰符：`(?i: ... )` 用于大小写不敏感匹配

转义规则按正则语义处理，而不是按字符串语义处理。常见转义包括 `\n`、`\r`、`\t`、`\f`、`\v`，以及 `\.`、`\(` 这类元字符转义，还有 Unicode 转义 `\uXXXX` / `\u{X...}`。如果要匹配字面量 `{`，请使用 `[{]`，不要写成 `\{`。这是为了给未来在正则字面量中支持插值预留语法空间，因为 `\{` 会和插值语法冲突。

还有一些重要语义和限制：

- `^` 和 `$` 是非多行锚点：只匹配整个输入的开头和结尾
- `\b` 和 `\B` 当前在正则字面量作为一等 `Regex` 值使用时可用；但在 [`=~`](https://docs.moonbitlang.cn/language/fundamentals.html#regex-match-expression) 这样的 `regex match expression` 常量上下文中暂不可用，未来这一限制预计会放宽。
- POSIX 字符类基于 ASCII
- 不支持 `\d`、`\D`、`\s`、`\S`、`\w` 和 `\W`。请改用 `[[:digit:]]`、`[^[:digit:]]`、`[[:space:]]`、`[^[:space:]]`、`[[:word:]]` 和 `[^[:word:]]`。
- `re"..."` 不支持 `\xHH` 字节转义；请改用 Unicode 转义或直接写普通字符。
- 不支持前瞻、后顾、反向引用和字符类集合运算
- 在字符类中，`-` 用于表示范围。若要匹配字面量连字符，请写 `\-`；不支持把 `-` 放在字符类开头或结尾来表示字面量。

具名捕获组（例如 `(?<id>[0-9]+)`）属于 `Regex` 值本身。它们可与 `Regex::execute` 和 `MatchResult::named_group` 等 API 配合使用，但不会自行引入 MoonBit 绑定变量。

当正则字面量作为一等 `Regex` 值使用时，`Regex::execute` 等操作采用 first-match 语义：它们返回从搜索位置开始找到的第一个匹配，不提供 longest-match 模式。

### 正则匹配表达式

正则匹配表达式使用 `=~` 运算符以正则常量表达式搜索 `StringView`。该表达式返回 `Bool`；只需单个布尔检查时使用它，多个正则分支返回不同结果时则使用 [`lexmatch`](https://docs.moonbitlang.cn/language/fundamentals.html#lexmatch)。

```
input =~ re"abc"
input =~ ((PREFIX + SUFFIX) as whole, before=head, after=tail)
input =~ (re"b", before~, after~)
```



右侧必须是正则常量表达式：可以是 `re"abc"` 这样的正则字面量、具名 `const`，或者由常量通过 `+`（拼接）、`|`（分支）和括号构造出来的表达式。不允许任意运行时值。

使用 `as` 绑定匹配到的子串。使用 `before` 和 `after` 将未匹配的前缀和后缀绑定为 `StringView`；`before~` 和 `after~` 是简写，分别绑定名为 `before` 和 `after` 的变量。

这和正则的具名捕获组是两回事。例如在 `re"(?<id>[0-9]+)"` 中，名称 `id` 属于正则引擎的捕获元数据，不是 MoonBit 绑定变量。如果你需要在 `=~` 中引入绑定，请使用 `as`，例如 `(re"(?<id>[0-9]+)" as digits)`。

和 `is` 一样，`=~` 引入的绑定可以用于相同的布尔流上下文，例如 `&&` 的右侧和 `if` 的 true 分支。正则匹配默认按搜索语义工作，因此 `"zabc!" =~ re"abc"` 的结果是 `true`。如果需要限制匹配必须发生在输入的开头或结尾，请使用 `^` 和 `$` 等锚点。

`=~` 同样采用 first-match 语义。它在设计上不会支持 longest-match 行为。

```
test {
  let input = " let_name = 42 "
  if (input =~ (
      (REGEX_IDENT_START + REGEX_IDENT_CONT) as ident,
      before=head,
      after=tail
    )) {
    assert_true(head is " ")
    assert_true(ident is "let_name")
    assert_true(tail is " = 42 ")
  } else {
    fail("expected identifier")
  }

  if ("abc" =~ (re"b", before~, after~)) {
    assert_true(before is "a")
    assert_true(after is "c")
  } else {
    fail("expected middle match")
  }

  let source : StringView = "abc"
  if (source =~ (re"." as ch, after=rest)) {
    assert_eq(ch, 'a')
    assert_true(rest is "bc")
  } else {
    fail("expected leading char")
  }

  assert_true("zabc!" =~ re"abc")
  assert_true(!("zabc!" =~ re"^abc"))
}
```



上面的例子中，`head`、`ident`、`tail`、`before`、`after` 和 `rest` 的类型都是 `StringView`。绑定变量 `ch` 的类型是 `Char`，因为 `re"."` 恰好匹配一个字符。

### Lexmatch

使用 `lexmatch` 将内存中的 `String` 或 `StringView` 与多个正则分支进行匹配，并求值所选分支的主体。其语法为：

```
lexmatch input [with first|longest] {
  regex_case => expression
  ...
  [catch_all => fallback_expression]
}
```



每个正则分支包含一个正则常量表达式，还可带有 `as`、`before=` 和 `after=` 绑定。不支持 `Bytes`、`BytesView` 及其他输入类型。

匹配策略决定如何处理相互重叠的 case：

- `first` 是默认策略。与 `match` 一样，各 case 按照从上到下的顺序具有优先级，并选择第一个正则能够匹配的 case。这是 case 优先级，而不是在不同 case 的匹配结果之间进行 leftmost-first 比较：即使靠前的未锚定 case 在输入中较晚的位置才匹配，它仍然优先于在较早位置匹配的靠后 case。
- `longest` 选择消耗最长输入前缀的 case。每个正则表达式都必须以 `^` 开头。如果多个 case 消耗的字符数相同，则按源码顺序决定优先级。该策略不支持 `*?`、`+?` 等非贪婪量词。

使用 `as` 绑定正则表达式或其子表达式匹配到的子串。捕获值的类型为 `StringView`；但如果编译器知道某个正则表达式恰好匹配一个字符，例如 `re"."`，则捕获值的类型为 `Char`。

`before=` 和 `after=` 将未匹配的前缀和后缀绑定为 `StringView`。简写形式 `before~` 和 `after~` 会绑定同名变量，而 `before=_` 和 `after=_` 会显式丢弃相应部分。首次匹配模式支持这两种绑定。最长匹配模式从输入开头开始，因此支持 `after=`，但不支持 `before=`。

对于首次匹配分支，应绑定或显式丢弃 `before` 和 `after`，也可以使用 `^` 和 `$` 明确预期的边界。对于最长匹配分支，当分支只消费输入前缀时请使用 `after=`；如果必须消费整个输入，则改为添加 `$`。

```
test "scan strings" {
  let text = "xx123yy"
  lexmatch text {
    (re"[0-9]+" as digits, before~, after~) => {
      inspect(before, content="xx")
      inspect(digits, content="123")
      inspect(after, content="yy")
    }
    _ => fail("")
  }

  lexmatch "letters123" with longest {
    (re"^[a-z]+" as word, after=rest) => {
      inspect(word, content="letters")
      inspect(rest, content="123")
    }
    _ => fail("")
  }
}
```



仅当正则分支无法覆盖所有可能的输入时，才需要兜底分支。如果编译器能证明正则分支是穷尽的，就可以省略兜底分支；否则会报告 [E4224](https://docs.moonbitlang.cn/language/error_codes/E4224.html)。存在的兜底分支必须位于最后；当没有正则分支匹配时，`rest` 之类的绑定会接收整个输入，而 `_` 会丢弃它。当正则分支或兜底分支永远无法选中时，编译器会报告 [E0090](https://docs.moonbitlang.cn/language/error_codes/E0090.html)。

### Lexscan

使用 `lexscan` 可连续消费词元，同时由它更新目标中存储的游标。目标可以是内存中的 `@lexbuf.StringScanner`、同步流式 `@lexbuf.Lexbuf` 或异步流式 `@lexbuf.AsyncLexbuf`。`lexscan` 与 `lexmatch` 使用相同的分支语法，以及 `first` 或 `longest` 策略：

```
lexscan input [with first|longest] {
  regex_case => expression
  ...
  [catch_all => fallback_expression]
}
```



这些扫描器类型需要直接导入 `moonbitlang/core/lexbuf`。这个可运行示例还导入了官方 `moonbitlang/async` 运行时，从而可以用 `async test` 测试异步扫描器：

```
import {
  "moonbitlang/async",
  "moonbitlang/core/lexbuf",
}
```



每个 `lexscan` 正则都必须以 `^` 开头，因为扫描总是从目标的当前游标处开始。`lexscan` 分支不支持 `before=` 或 `after=`。它们仍可使用 `as` 绑定匹配文本，其 `StringView` 和 `Char` 捕获类型与 `lexmatch` 相同。

在 `first` 模式下，`lexscan` 与 `match` 一样从上到下尝试各 case，并选择第一个在当前游标处匹配的正则。这里的 `first` 指 case 优先级；它不会在 case 之间比较最靠左的匹配位置或匹配长度。由于每个 `lexscan` 正则都用 `^` 锚定，因此所有 case 都从同一个当前游标位置开始尝试。

`String` 或 `StringView` 值不是有效的 `lexscan` 目标。如只需匹配一个内存值，请使用 `lexmatch`；如需让连续多次扫描共享游标，请将 `StringView` 放入 `StringScanner`。不支持 `Bytes`、`BytesView` 及用户自定义的类词法缓冲区类型。

#### 字符串扫描器

`@lexbuf.StringScanner` 扫描内存中的 `StringView`。在遵守上述 `lexscan` 限制的前提下，其分支选择和捕获相当于从 `scanner.cursor` 开始，对 `scanner.data` 尚未消费的部分应用 `lexmatch`。选中正则分支后，`lexscan` 会将 `scanner.cursor` 更新为匹配末尾的位置。因此，同一扫描器可以连续传给多次调用，而无需切分输入或手动更新偏移量。

构造字符串扫描器时，将其游标设为 `0`：

```
let scanner = @lexbuf.StringScanner::{ data: text[:], cursor: 0 }
```



游标和 `StringView` 索引都以 UTF-16 代码单元为单位。游标相对于 `data`，且必须位于 `0..=data.length()` 范围内，因此 `data` 本身可以是更大字符串的切片。兜底分支必须写成 `_`；它不会推进游标。

以下扫描器会跳过空白，并在每次调用时返回一个词元。测试还展示了 `lexscan` 如何维护游标：

```
priv enum Token {
  Word(StringView)
  Integer(StringView)
  Punctuation(Char)
  Eof
}

///|
fn next_string_token(input : @lexbuf.StringScanner) -> Token {
  lexscan input with longest {
    re"^[[:space:]]+" => next_string_token(input)
    re"^[[:alpha:]]+" as word => Word(word)
    re"^[[:digit:]]+" as digits => Integer(digits)
    re"^." as mark => Punctuation(mark)
    _ => Eof
  }
}

///|
test "scan an in-memory string with a maintained cursor" {
  let input = @lexbuf.StringScanner::{ data: "hello 123!"[:], cursor: 0 }
  guard next_string_token(input) is Word(word) else { fail("expected word") }
  assert_true(word == "hello")
  assert_eq(input.cursor, 5)
  guard next_string_token(input) is Integer(digits) else {
    fail("expected integer")
  }
  assert_true(digits == "123")
  assert_eq(input.cursor, 9)
  guard next_string_token(input) is Punctuation(mark) else {
    fail("expected punctuation")
  }
  assert_true(mark == '!')
  assert_eq(input.cursor, input.data.length())
  assert_true(next_string_token(input) is Eof)
  assert_eq(input.cursor, input.data.length())
}
```



#### 流式扫描器

`Lexbuf` 和 `AsyncLexbuf` 会在多次 `lexscan` 调用之间保留游标。正则分支匹配成功后，会消费匹配到的前缀，并将游标提交到该匹配的末尾。这使得递归或重复调用的扫描器能像词法分析器一样工作。模式可以跨越 `from_fn` 提供的任意多个数据块；数据块边界不会结束词元。

与 `lexmatch` 一样，仅当正则分支不穷尽时才需要兜底分支。`lexscan` 兜底分支必须写成 `_`：它处理 EOF 或其他无法匹配的字符，不绑定剩余输入，也不推进目标游标。

以下扫描器会跳过空白，并在每次调用时返回一个 token：

```
priv enum StreamToken {
  StreamWord(StringView)
  StreamInteger(StringView)
  StreamPunctuation(Char)
  StreamEof
}

///|
fn next_token(input : @lexbuf.Lexbuf) -> StreamToken {
  lexscan input with longest {
    re"^[[:space:]]+" => next_token(input)
    re"^[[:alpha:]]+" as word => StreamWord(word)
    re"^[[:digit:]]+" as digits => StreamInteger(digits)
    re"^." as mark => StreamPunctuation(mark)
    _ => StreamEof
  }
}

///|
test "scan a synchronous stream" {
  let chunks = ["hello ", "123!"][:].iter()
  let input = @lexbuf.Lexbuf::from_fn(() => chunks.next())
  guard next_token(input) is StreamWord(word) else { fail("expected word") }
  assert_true(word == "hello")
  guard next_token(input) is StreamInteger(digits) else {
    fail("expected integer")
  }
  assert_true(digits == "123")
  guard next_token(input) is StreamPunctuation(mark) else {
    fail("expected punctuation")
  }
  assert_true(mark == '!')
  assert_true(next_token(input) is StreamEof)
}
```



`AsyncLexbuf` 具有相同的匹配和游标语义。它的数据源是 `async () -> String?` 函数，因此扫描它的函数也必须是 `async`。MoonBit 没有 `await` 关键字；在异步代码中正常调用异步扫描器即可。

```
/// Returns the next alphabetic token from an asynchronous lexbuf.
pub async fn next_word(input : @lexbuf.AsyncLexbuf) -> StringView? {
  lexscan input {
    re"^[[:alpha:]]+" as word => Some(word)
    _ => None
  }
}
```



`lexmatch` 和 `lexscan` 的分支主体不能带 guard。表达式会先选择分支，再求值其主体，因此请将其他条件放到主体内部。

### 旧版词法模式语法

较早的实验版本使用由字符串片段组成的 `lexmatch` 模式，以及布尔形式 `lexmatch?`。这些形式已经移除。现在，`lexmatch` 关键字表示上文所述的内存中正则分支表达式。

例如，旧代码可能如下：

```
lexmatch text {
  (before, "a" ("b*" as b) "c", after) => ...
  _ => ...
}

if text lexmatch? ("a" ("b*" as b) "c") && b.length() > 0 {
  ...
}
```



将基于分支的代码转换为使用正则常量表达式的 `lexmatch`。单个布尔搜索则使用 [`=~`](https://docs.moonbitlang.cn/language/fundamentals.html#regex-match-expression)。

### 展开运算符

MoonBit 提供了一个展开运算符，用于在使用数组字面量语法构造 `Array`、`String`和 `Bytes` 时展开元素序列。要展开这样的序列，需要在其前面加上 `..` 前缀，并且该序列必须具有 `iter()` 方法，并且该方法能够产生相应类型的元素。

例如，我们可以使用展开运算符构造一个数组：

```
test {
  let a1 : Array[Int32] = [1, 2, 3]
  let a2 : FixedArray[Int32] = [4, 5, 6]
  let a3 : @list.List[Int32] = @list.List([7, 8, 9])
  let a : Array[Int32] = [..a1, ..a2, ..a3, 10]
  debug_inspect(a, content="[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]")
}
```



条件展开 `..if condition { sequence }` 只在条件为真时加入该序列：

```
test {
  let include_middle = true
  let values = [1, ..if include_middle { [2, 3] }, 4]
  assert_eq(values, [1, 2, 3, 4])

  let without_middle = [1, ..if false { [2, 3] }, 4]
  assert_eq(without_middle, [1, 4])
}
```



同样，我们可以使用展开运算符构造一个字符串：

```
test {
  let s1 : String = "Hello"
  let s2 : StringView = "World".view()
  let s3 : Array[Char] = [..s1, ' ', ..s2, '!']
  let s : String = [..s1, ' ', ..s2, '!', ..s3]
  inspect(s, content="Hello World!Hello World!")
}
```



最后一个例子展示了如何使用展开运算符构造一个字节序列。

```
test {
  let b1 : Bytes = b"hello"
  let b2 : BytesView = b1[1:4]
  let b : Bytes = [..b1, ..b2, 10]
  inspect(
    b,
    content=(
      #|b"helloell\x0a"
    ),
  )
}
```



### TODO 语法

`todo`语法 (`...`) 是一种特殊构造，用于标记尚未实现或用于未来功能的占位符代码段。例如：

```
fn todo_in_func() -> Int32 {
  ...
}
```

# 方法和特征

## 方法系统

MoonBit 支持方法的方式与传统的面向对象语言不同。MoonBit 中的方法只是与类型构造器关联的顶层函数。定义方法时，在函数名之前添加 `SelfTypeName::` 前缀，例如 `fn SelfTypeName::method_name(...)`，这样方法就属于 `SelfTypeName`。在方法的签名内，可以用 `Self` 来指代 `SelfTypeName`。

警告

目前，MoonBit 支持一种定义方法的简短语法。当某个函数定义的第一个参数的名字是 `self` 时，它会被视作 `self` 的类型上的方法定义。这一语法在未来可能会被废弃，我们不鼓励在新代码中使用这一写法。

```
fn method_name(self : SelfType) -> Unit { ... }
```



```
enum List[X] {
  Nil
  Cons(X, List[X])
}

///|
fn[X] List::length(xs : List[X]) -> Int32 {
  ...
}
```



要调用一个方法，可以使用语法 `T::method_name(..)`，或者当其中第一个参数是 `T` 的类型时使用点调用：

```
let l : List[Int32] = Nil
println(l.length())
println(List::length(l))
```



当方法的第一个参数也是它所属的类型时，可以使用点语法 `x.method(...)` 调用方法。MoonBit 根据 `x` 的类型自动找到正确的方法，无需编写方法的类型名称甚至包名称：

```
pub(all) enum List[X] {
  Nil
  Cons(X, List[X])
}

pub fn[X] List::concat(list : List[List[X]]) -> List[X] {
  ...
}
```



以别名 list 使用包

```
// 假设 `xs` 是一个列表的列表，那么下面两种写法是等价的：
let _ = xs.concat()
let _ = @list.List::concat(xs)
```



用 `TypeName::method_name` 形式定义出的方法支持重载：由于不同类型的方法处于不同的命名空间中，不同的类型可以定义同名的方法。

```
struct T1 {
  x1 : Int32
}

fn T1::default() -> T1 {
  { x1: 0 }
}

struct T2 {
  x2 : Int32
}

fn T2::default() -> T2 {
  { x2: 0 }
}

test {
  let t1 = T1::default()
  let t2 = T2::default()

}
```



### 本地方法

为了保证方法定义只有单一来源并规避歧义，[只能在类型所在的包里定义方法](https://docs.moonbitlang.cn/language/packages.html#trait-implementations)。然而，这条规则有一个例外：MoonBit 允许给来自外部的类型定义 *私有* 方法。这些本地方法可以覆盖来自类型自己的包的方法（但此时 MoonBit 会报一个警告），为上游包的 API 提供拓展和补充：

```
fn Int32::my_int_method(self : Int32) -> Int32 {
  self * self + self
}

test {
  assert_eq((6).my_int_method(), 42)
}
```



### 通过别名把方法变成函数

MoonBit 允许用户用别名来调用一个方法。声明方法别名的语法如下：

方法别名会创建一个同名的方法。你也可以选择创建一个同名的函数。别名的可见性也可以被控制。

```
#alias(m)
#alias(n, visibility="priv")
#as_free_fn(m)
#as_free_fn(n, visibility="pub")
fn List::f() -> Bool {
  true
}
test {
  assert_eq(List::f(), List::m())
  assert_eq(List::m(), m())
}
```



## 运算符重载

MoonBit 通过内建的特征支持中缀运算符的重载，例如：

```
struct T {
  x : Int32
}

impl Add for T with add(self : T, other : T) -> T {
  { x: self.x + other.x }
}

test {
  let a = T::{ x: 0 }
  let b = T::{ x: 2 }
  assert_eq((a + b).x, 2)
}
```



其他运算符通过带有属性的方法重载，例如 `_[_]` 和 `_[_]=_`：

```
struct Coord {
  mut x : Int32
  mut y : Int32
}

#alias("_[_]")
fn Coord::get(coord : Self, key : String) -> Int32 {
  match key {
    "x" => coord.x
    "y" => coord.y
  }
}

#alias("_[_]=_")
fn Coord::set(coord : Self, key : String, val : Int32) -> Unit {
  match key {
    "x" => coord.x = val
    "y" => coord.y = val
  }
}
```



```
fn main {
  let c = Coord::{ x: 1, y: 2 }
  println("{x: \{c.x}, y: \{c.y}}")
  println(c["y"])
  c["x"] = 23
  println("{x: \{c.x}, y: \{c.y}}")
  println(c["x"])
}
```



输出

```
{x: 1, y: 2}
2
{x: 23, y: 2}
23
```



目前，可以重载以下运算符：

| 运算符名称           | 重载方式                |
| -------------------- | ----------------------- |
| `+`                  | 特征 `Add`              |
| `-`                  | 特征 `Sub`              |
| `*`                  | 特征 `Mul`              |
| `/`                  | 特征 `Div`              |
| `%`                  | 特征 `Mod`              |
| `==`                 | 特征 `Eq`               |
| `<<`                 | 特征 `Shl`              |
| `>>`                 | 特征 `Shr`              |
| `-`（一元）          | 特征 `Neg`              |
| `_[_]`（获取项）     | method + alias `_[_]`   |
| `_[_] = _`（设置项） | method + alias `_[_]=_` |
| `_[_:_]`（视图）     | method + alias `_[_:_]` |
| `&`                  | 特征 `BitAnd`           |
| `|`                  | 特征 `BitOr`            |
| `^`                  | 特征 `BitXOr`           |

在重载 `_[_]`/`_[_] = _`/`_[_:_]` 时，定义的方法需要有正确的类型签名：

- `_[_]` 的签名应该形如 `(Self, Index) -> Result`，使用方式为 `let result = self[index]`
- `_[_]=_` 的签名应该形如 `(Self, Index, Value) -> Unit`，使用方式为 `self[index] = value`
- `_[_:_]` 的签名应当形如 `(Self, start? : Index, end? : Index) -> Result`，使用方式为 `let result = self[start:end]`

对于 `_[_:_]`，范围边界也可以有显式默认值，例如 `start~ : Index = default_expr`，如下例所示。

通过实现 `_[_:_]` 方法，可以为用户定义的类型创建视图。以下是一个例子：

```
struct DataView(String)

struct Data {}

#alias("_[_:_]")
fn Data::as_view(_self : Data, start~ : Int32 = 0, end? : Int32) -> DataView {
  "[\{start}, \{end.unwrap_or(100)})"
}

test {
  let data = Data::{  }
  inspect(data[:].0, content="[0, 100)")
  inspect(data[2:].0, content="[2, 100)")
  inspect(data[:5].0, content="[0, 5)")
  inspect(data[2:5].0, content="[2, 5)")
}
```



## Trait（特征）系统

MoonBit 具有用于重载/特殊多态的结构特征系统。特征声明一系列操作，当类型想要实现特征时，必须提供这些操作。特征可以如下声明：

```
pub(open) trait I {
  method_(Int32) -> Int32
  method_with_label(Int32, label~ : Int32) -> Int32
  //! method_with_label(Int32, label?: Int32) -> Int32
}
```



在特征定义的主体中，使用特殊类型 `Self` 来引用实现特征的类型。

### 扩展特征

特征（子特征）可以依赖于其他特征（超特征），例如：

```
pub(open) trait Position {
  pos(Self) -> (Int32, Int32)
}

pub(open) trait Draw {
  draw(Self, Int32, Int32) -> Unit
}

pub(open) trait Object: Position + Draw {}
```



### 实现特征

如果某类型想要实现一个特征，它需要显式地实现特征中的所有方法。实现特征方法的语法是 `impl Trait for Type with method_name(...) { ... }`，例如：

```
pub(open) trait MyShow {
  to_string(Self) -> String
}

struct MyType {}

pub impl MyShow for MyType with to_string(self) {
  ...
}

pub extend MyType with MyShow::{to_string}

struct MyContainer[_] {}

/// trait implementation with type parameters.
/// `[X : Show]` means the type parameter `X` must implement `Show`,
/// this will be covered later.
pub impl[X : MyShow] MyShow for MyContainer[X] with to_string(self) {
  ...
}

pub extend MyContainer with MyShow::{to_string}
```



`impl` 实现的类型注释可以省略：MoonBit 将根据 `Trait::method` 的签名和 self 类型自动推断类型。

特征的作者还可以为特征中的某些方法定义**默认实现**，例如：

```
pub(open) trait J {
  f(Self) -> Unit
  f_twice(Self) -> Unit = _
}

impl J with f_twice(self) {
  self.f()
  self.f()
}
```



注意除了实际的默认实现 `impl J with f_twice` 外，在 `J` 中、`f_twice` 的声明里，还需要提供一个 `= _` 标记。这一标记能让代码的读者一眼知道哪些方法有默认实现，改善可读性。

`J` 的类型实现特征时不必为 `f_twice` 提供实现：要实现 `J`，只有 `f` 是必要的。如果需要，他们总是可以显式地用 `impl J for Type with f_twice` 覆盖默认实现。

```
impl J for Int32 with f(self) {
  println(self)
}

impl J for String with f(self) {
  println(self)
}

impl J for String with f_twice(self) {
  println(self)
  println(self)
}
```



要实现子特征，必须实现超特征，以及子特征中的方法。

```
impl Position for Point with pos(self) {
  (self.x, self.y)
}

impl Draw for Point with draw(self, x, y) {
  ()
}

impl Object for Point

pub fn[O : Object] draw_object(obj : O) -> Unit {
  let (x, y) = Position::pos(obj)
  Draw::draw(obj, x, y)
}

test {
  let p = Point::{ x: 1, y: 2 }
  draw_object(p)
}
```



在受子 trait 约束的泛型函数中，请使用 `Position::pos(obj)` 这样的限定语法调用继承自父 trait 的方法。由于这类方法来自父 trait，而不是直接写出的约束，因此已弃用通过点语法在类型参数上调用它们。

即使一个特征的每个方法都有默认实现，也依然需要显式实现它，否则 [抽象特征](https://docs.moonbitlang.cn/language/packages.html#traits) 等功能无法工作。为此，MoonBit 提供了 `impl Trait for Type` 语法（去除了方法部分，除此之外与前面的 `impl` 相同）`impl Trait for Type` 保证了 `Type` 会实现 `Trait`，MoonBit 会自动检查 `Trait` 中的每个方法是否都有对应的实现。

除了用于处理每个方法都有默认实现的特征，`impl Trait for Type` 还可以用作文档，或是在实际完成实现之前的一个待办标记。

警告

目前，没有任何方法的空特征会自动实现。

#### 使用 `extend` 附加 trait 方法

`impl Trait for Type` 声明记录 `Type` 实现了 `Trait`。使用 `extend` 声明可以把选定的 trait 方法显式附加到类型上，从而通过点语法调用：

```
struct MyCustomType {}

pub impl Show for MyCustomType with output(self, logger) {
  ...
}

pub extend MyCustomType with Show::{to_string, output}

fn f() -> Unit {
  let x = MyCustomType::{  }
  let _ = x.to_string()
}
```



一般形式为 `extend Type with Trait::{method1, method2}`。添加 `pub` 会把附加的方法公开；不加 `pub` 时，这些方法仅在当前包中可用。私有类型仍可使用私有的 `extend` 声明。

当附加的 trait 方法使用默认实现时，该实现中的 `Self` 会特化为 `Type`。trait object 类型也可以扩展，例如 `extend &Derived with Super::{method}`。

自动附加 `impl` 中所有方法的行为已经弃用。它不仅是隐式的，也不具备重构安全性：上游 trait 新增带默认实现的方法后，已有的点调用可能产生歧义。库作者应为需要点语法调用的方法添加显式 `extend`；如果无意提供方法式 API，则继续使用 `Trait::method(value, ...)`。

为兼容旧代码，编译器仍接受旧的隐式方法附加行为，并默认报告 `implicit_impl_as_method` 弃用诊断。对于抽象特征，仅声明 `pub impl` 不会触发该诊断；使用隐式附加的方法时才会触发。新代码应使用 `extend`，而不是依赖这种兼容行为。

如果某个隐式附加的方法需要暂时保持可调用、但不属于预期的方法式 API，请添加对应的 `extend` 声明并用 `#deprecated` 标记。这样既能为下游代码保留迁移路径，也能引导用户改用 `Trait::method(value)` 等限定调用。

### 使用特征

在声明泛型函数时，可以使用特征注释类型参数，来定义受约束的泛型函数。例如：

```
fn[X : Eq] contains(xs : Array[X], elem : X) -> Bool {
  for x in xs {
    if x == elem {
      return true
    }
  } nobreak {
    false
  }
}
```



如果没有 `Eq` 要求，`contains` 中的表达式 `x == elem` 将产生类型错误。现在，函数 `contains` 可以使用任何实现 `Eq` 的类型调用，例如：

```
struct Point {
  x : Int32
  y : Int32
}

impl Eq for Point with equal(p1, p2) {
  p1.x == p2.x && p1.y == p2.y
}

test {
  assert_false(contains([1, 2, 3], 4))
  assert_true(contains([1.5, 2.25, 3.375], 2.25))
  assert_false(contains([{ x: 2, y: 3 }], { x: 4, y: 9 }))
}
```



#### 直接调用特征方法

可以通过 `Trait::method` 直接调用特征的方法。MoonBit 将推断 `Self` 的类型，并检查 `Self` 是否确实实现了 `Trait`，例如：

```
test {
  assert_eq(Show::to_string(42), "42")
  assert_eq(Compare::compare(1.0, 2.5), -1)
}
```



为了让具体类型的 API 经得起未来演进，请使用 [`extend`](https://docs.moonbitlang.cn/language/methods.html#attaching-trait-methods-with-extend) 显式附加需要支持点语法的 trait 方法。普通方法的优先级高于附加的 trait 方法。为保持兼容，现有的隐式点调用仍会被接受，但已经弃用。

对于类型参数，来自唯一一个显式约束的方法可以使用点语法。继承自父 trait 的方法应使用限定语法；当类型参数有多个约束时，所有 trait 方法都应使用限定语法，从而明确所选 trait。trait object 也遵循同样原则：使用限定语法调用父 trait 方法，或显式扩展该 trait object 类型。

## 特征对象

MoonBit 支持通过特征对象实现运行时多态。如果 `t` 是类型 `T`，它实现了特征 `I`，可以通过 `t as &I` 将实现 `I` 的 `T` 的方法与 `t` 一起打包到运行时对象中。如果从上下文可以知道某个表达式的类型是特征对象类型，则 `as &I` 可以省略。特征对象擦除了值的具体类型，因此可以将从不同具体类型创建的对象放入相同的数据结构并统一处理：

```
pub(open) trait Animal {
  speak(Self) -> String
}

struct Duck(String)

fn Duck::make(name : String) -> Duck {
  Duck(name)
}

impl Animal for Duck with speak(self) {
  "\{self.0}: quack!"
}

struct Fox(String)

fn Fox::make(name : String) -> Fox {
  Fox(name)
}

impl Animal for Fox with speak(_self) {
  "What does the fox say?"
}

test {
  let duck1 = Duck::make("duck1")
  let duck2 = Duck::make("duck2")
  let fox1 = Fox::make("fox1")
  let animals : Array[&Animal] = [duck1, duck2, fox1]
  debug_inspect(
    animals.map(fn(animal) { animal.speak() }),
    content=(
      #|["duck1: quack!", "duck2: quack!", "What does the fox say?"]
    ),
  )
}
```



并非所有特征都可以用于创建对象。“对象安全”特征的方法必须满足以下条件：

- `Self` 必须是方法的第一个参数
- 方法的类型中只能出现一个 `Self`（即第一个参数）

用户可以为特征对象定义新方法，就像为结构体和枚举定义新方法一样：

```
pub(open) trait Logger {
  write_string(Self, String) -> Unit
}

pub(open) trait CanLog {
  log(Self, &Logger) -> Unit
}

fn[Obj : CanLog] &Logger::write_object(self : &Logger, obj : Obj) -> Unit {
  obj.log(self)
}

/// 使用新的方法来简化代码
pub impl[A : CanLog, B : CanLog] CanLog for (A, B) with log(self, logger) {
  let (a, b) = self
  logger
  ..write_string("(")
  ..write_object(a)
  ..write_string(", ")
  ..write_object(b)
  .write_string(")")
}
```



## 内建特征

MoonBit 提供了以下有用的内建特征：

```
trait Eq {
  op_equal(Self, Self) -> Bool
}

trait Compare : Eq {
  // `0` 代表相等，`-1` 代表小于，`1` 代表大于
  compare(Self, Self) -> Int32
}

trait Hash {
  hash_combine(Self, Hasher) -> Unit // 待实现
  hash(Self) -> Int32 // 有默认实现
}

trait Show {
  output(Self, Logger) -> Unit // 待实现
  to_string(Self) -> String // 有默认实现
}

trait Default {
  default() -> Self
}
```



### 派生内建特征

MoonBit 可以自动为一些内建特征派生实现：

```
struct T {
  a : Int32
  b : Int32
} derive(Eq, Compare, Debug, Default)

pub extend T with Eq::{not_equal, equal}

pub extend T with Compare::{op_lt, op_le, op_ge, compare, op_gt}

pub extend T with Debug::{to_repr}

pub extend T with Default::{default}

test {
  let t1 : T = Default::default()
  let t2 = T::{ a: 1, b: 1 }
  debug_inspect(t1, content="{ a: 0, b: 0 }")
  debug_inspect(t2, content="{ a: 1, b: 1 }")
  assert_false(t1 == t2)
  assert_true(t1 < t2)
}
```



参见 [派生](https://docs.moonbitlang.cn/language/derive.html) 了解有关派生特征的更多信息。

# 派生内建特征

MoonBit 支持从类型定义中自动派生一些内建特征。

要派生特征 `T`，类型中使用的所有字段都必须实现 `T`。例如，为结构体 `struct A { x: T1; y: T2 }` 派生 `Show` 需要 `T1 : Show` 和 `T2 : Show`。

`derive` 会生成 trait 实现。下面的示例还使用 [`extend`](https://docs.moonbitlang.cn/language/methods.html#attaching-trait-methods-with-extend) 显式声明哪些生成的 trait 函数属于该类型的方法式 API，从而避免依赖已弃用的从实现中隐式附加方法的行为。

## 相等和比较

`derive(Eq)` 和 `derive(Compare)` 会生成用于测试相等性和比较的相应实现。字段按照定义顺序进行比较。对于枚举，构造器的顺序按照定义顺序升序排列。

```
struct DeriveEqCompare {
  x : Int32
  y : Int32
} derive(Eq, Compare)

pub extend DeriveEqCompare with Eq::{not_equal, equal}

pub extend DeriveEqCompare with Compare::{op_lt, op_le, op_ge, compare, op_gt}

test "derive eq_compare struct" {
  let p1 = DeriveEqCompare::{ x: 1, y: 2 }
  let p2 = DeriveEqCompare::{ x: 2, y: 1 }
  let p3 = DeriveEqCompare::{ x: 1, y: 2 }
  let p4 = DeriveEqCompare::{ x: 1, y: 3 }

  // Eq
  assert_eq(p1 == p2, false)
  assert_eq(p1 == p3, true)
  assert_eq(p1 == p4, false)
  assert_eq(p1 != p2, true)
  assert_eq(p1 != p3, false)
  assert_eq(p1 != p4, true)

  // Compare
  assert_eq(p1 < p2, true)
  assert_eq(p1 < p3, false)
  assert_eq(p1 < p4, true)
  assert_eq(p1 > p2, false)
  assert_eq(p1 > p3, false)
  assert_eq(p1 > p4, false)
  assert_eq(p1 <= p2, true)
  assert_eq(p1 >= p2, false)
}
```



```
enum DeriveEqCompareEnum {
  Case1(Int32)
  Case2(label~ : String)
  Case3
} derive(Eq, Compare)

pub extend DeriveEqCompareEnum with Eq::{not_equal, equal}

pub extend DeriveEqCompareEnum with Compare::{op_lt, op_le, op_ge, compare, op_gt}

test "derive eq_compare enum" {
  let p1 = DeriveEqCompareEnum::Case1(42)
  let p2 = DeriveEqCompareEnum::Case1(43)
  let p3 = DeriveEqCompareEnum::Case1(42)
  let p4 = DeriveEqCompareEnum::Case2(label="hello")
  let p5 = DeriveEqCompareEnum::Case2(label="world")
  let p6 = DeriveEqCompareEnum::Case2(label="hello")
  let p7 = DeriveEqCompareEnum::Case3

  // Eq
  assert_eq(p1 == p2, false)
  assert_eq(p1 == p3, true)
  assert_eq(p1 == p4, false)
  assert_eq(p1 != p2, true)
  assert_eq(p1 != p3, false)
  assert_eq(p1 != p4, true)

  // Compare
  assert_eq(p1 < p2, true) // 42 < 43
  assert_eq(p1 < p3, false)
  assert_eq(p1 < p4, true) // Case1 < Case2
  assert_eq(p4 < p5, true)
  assert_eq(p4 < p6, false)
  assert_eq(p4 < p7, true) // Case2 < Case3
}
```



## Debug

`derive(Debug)` 会为类型生成结构化的调试实现。它可用于测试中的 `debug_inspect`，也可在格式化诊断信息时配合 `@debug.to_string` 使用。

```
struct DebugPoint {
  x : Int32
  y : Int32
} derive(Debug)

pub extend DebugPoint with Debug::{to_repr}

test "derive debug struct" {
  let point = DebugPoint::{ x: 1, y: 2 }
  debug_inspect(point, content="{ x: 1, y: 2 }")
}
```



枚举也可以派生 `Debug`：

```
enum DebugShape {
  Circle(radius~ : Int32)
  Rect(width~ : Int32, height~ : Int32)
} derive(Debug)

pub extend DebugShape with Debug::{to_repr}

test "derive debug enum" {
  let shape = DebugShape::Rect(width=3, height=4)
  debug_inspect(shape, content="Rect(width=3, height=4)")
}
```



## 默认值

`derive(Default)` 会为该类型生成 `Default` 实现。调用 `Default::default()` 时需要提供预期类型，以便 MoonBit 选择相应的实现。如果还希望让 `default` 成为该类型的方法式 API 的一部分，请显式声明 `extend`。

对于结构体，默认值是所有字段设置为它们的默认值的结构体。

```
struct DeriveDefault {
  x : Int32
  y : String?
} derive(Default, Eq)

pub extend DeriveDefault with Default::{default}

pub extend DeriveDefault with Eq::{not_equal, equal}

test "derive default struct" {
  let p : DeriveDefault = Default::default()
  assert_true(p == DeriveDefault::{ x: 0, y: None })
}
```



对于枚举，默认值是唯一没有参数的构造器。

```
enum DeriveDefaultEnum {
  Case1(Int32)
  Case2(label~ : String)
  Case3
} derive(Default, Eq)

pub extend DeriveDefaultEnum with Default::{default}

pub extend DeriveDefaultEnum with Eq::{not_equal, equal}

test "derive default enum" {
  let value : DeriveDefaultEnum = Default::default()
  assert_true(value == DeriveDefaultEnum::Case3)
}
```



没有构造器或有多个没有参数的构造器的枚举不能派生 `Default`。

```
enum CannotDerive1 {
    Case1(String)
    Case2(Int32)
} derive(Default) // cannot find a constant constructor as default

enum CannotDerive2 {
    Case1
    Case2
} derive(Default) // Case1 and Case2 are both candidates as default constructor
```



## 哈希值

`derive(Hash)` 将为类型生成一个哈希实现。这将允许类型在期望 `Hash` 实现的地方使用，例如 `HashMap` 和 `HashSet`。

```
struct DeriveHash {
  x : Int32
  y : String?
} derive(Hash, Eq)

pub extend DeriveHash with Hash::{hash, hash_combine}

pub extend DeriveHash with Eq::{not_equal, equal}

test "derive hash struct" {
  let hs = @hashset.HashSet([])
  hs.add(DeriveHash::{ x: 123, y: None })
  hs.add(DeriveHash::{ x: 123, y: None })
  @test.assert_eq(hs.length(), 1)
  hs.add(DeriveHash::{ x: 123, y: Some("456") })
  @test.assert_eq(hs.length(), 2)
}
```



## 任意值

`derive(Arbitrary)` 将生成给定类型的随机值。

## 缩小

`derive(Shrink)` 为基于属性的测试实现 `@quickcheck.Shrink`。结构体字段按源码顺序逐个缩小。枚举值在缩小负载时保持当前构造器；不带负载的构造器不会产生候选值。派生实现使用的每个字段或负载本身都必须实现 `Shrink`。

```
///|
struct ShrinkPoint {
  x : Int32
  y : Int32
} derive(Shrink)

///|
pub extend ShrinkPoint with @shrink.Shrink::{shrink}

///|
fn shrink_candidates(point : ShrinkPoint) -> Iter[ShrinkPoint] {
  @quickcheck.Shrink::shrink(point)
}

///|
test "derive shrink struct" {
  let candidates = shrink_candidates(ShrinkPoint::{ x: 10, y: 20, }).collect()
  assert_true(candidates.length() > 0)
}
```



## 从/到 Json

`derive(FromJson)` 和 `derive(ToJson)` 会自动生成可往返的 trait 实现，用于将类型序列化为 JSON 以及从 JSON 反序列化。可以使用限定语法调用 trait 函数，例如 `ToJson::to_json(value)`。该实现主要用于调试和以人类可读的格式存储类型。

```
struct JsonTest1 {
  x : Int32
  y : Int32
} derive(FromJson, ToJson, Eq)

pub extend JsonTest1 with @moonbitlang/core/json.FromJson::{from_json}

pub extend JsonTest1 with ToJson::{to_json}

pub extend JsonTest1 with Eq::{not_equal, equal}

enum JsonTest2 {
  A(x~ : Int32)
  B(x~ : Int32, y~ : Int32)
} derive(FromJson(style="legacy"), ToJson(style="legacy"), Eq)

pub extend JsonTest2 with @moonbitlang/core/json.FromJson::{from_json}

pub extend JsonTest2 with ToJson::{to_json}

pub extend JsonTest2 with Eq::{not_equal, equal}

test "json basic" {
  let input = JsonTest1::{ x: 123, y: 456 }
  let expected : Json = { "x": 123, "y": 456 }
  @test.assert_eq(ToJson::to_json(input), expected)
  assert_true(@json.from_json(expected) == input)
  let input = JsonTest2::A(x=123)
  let expected : Json = { "$tag": "A", "x": 123 }
  @test.assert_eq(ToJson::to_json(input), expected)
  assert_true(@json.from_json(expected) == input)
}
```



这两个派生指令都接受一些参数来配置序列化和反序列化的确切行为。

警告

JSON 序列化参数的实际行为是不稳定的。

警告

JSON 派生参数仅用于粗粒度控制派生格式。如果你需要精确控制类型的布局，请考虑 **直接实现这两个特征**。

我们最近弃用了大量高级布局调整参数。对于这种用法和将来对它们的使用，请手动实现这些特征。这些参数包括：`repr`、`case_repr`、`default`、`rename_all` 等。

```
struct JsonTest3 {
  x : Int32
  y : Int32
} derive (
  FromJson(fields(x(rename="renamedX"))),
  ToJson(fields(x(rename="renamedX"))),
  Eq,
)

pub extend JsonTest3 with @moonbitlang/core/json.FromJson::{from_json}

pub extend JsonTest3 with ToJson::{to_json}

pub extend JsonTest3 with Eq::{not_equal, equal}

enum JsonTest4 {
  A(x~ : Int32)
  B(x~ : Int32, y~ : Int32)
} derive(FromJson, ToJson, Eq)

pub extend JsonTest4 with @moonbitlang/core/json.FromJson::{from_json}

pub extend JsonTest4 with ToJson::{to_json}

pub extend JsonTest4 with Eq::{not_equal, equal}

test "json args" {
  let input = JsonTest3::{ x: 123, y: 456 }
  let expected : Json = { "renamedX": 123, "y": 456 }
  @test.assert_eq(ToJson::to_json(input), expected)
  assert_true(@json.from_json(expected) == input)
  let input = JsonTest4::A(x=123)
  let expected : Json = ["A", { "x": 123 }]
  @test.assert_eq(ToJson::to_json(input), expected)
  assert_true(@json.from_json(expected) == input)
}
```



### 枚举样式

目前有两种枚举序列化样式：`legacy` 和 `flat`，用户必须使用 `style` 参数选择其中一种。

```
enum E {
  One
  Uniform(Int32)
  Axes(x~: Int32, y~: Int32)
}
```



使用 `derive(ToJson(style="legacy"))`，枚举格式化为：

```
E::One              => { "$tag": "One" }
E::Uniform(2)       => { "$tag": "Uniform", "0": 2 }
E::Axes(x=-1, y=1)  => { "$tag": "Axes", "x": -1, "y": 1 }
```



使用 `derive(ToJson(style="flat"))`，枚举格式化为：

```
E::One              => "One"
E::Uniform(2)       => [ "Uniform", 2 ]
E::Axes(x=-1, y=1)  => [ "Axes", -1, 1 ]
```



#### 派生 `Option`

一个特例是内建类型 `Option[T]`。理想情况下，它会被解释为 `T | undefined`，但问题是对于 `Option[Option[T]]` 来说，无法区分 `Some(None)` 和 `None`。

因此，当且仅当它是结构体的直接字段时，它被解释为 `T | undefined`，否则解释为 `[T] | null`：

```
struct A {
  x : Int32?
  y : Int32??
  z : (Int32?, Int32??)
} derive(ToJson)

pub extend A with ToJson::{to_json}

test {
  json_inspect({ x: None, y: None, z: (None, None) }, content={
    "z": [null, null],
  })
  json_inspect({ x: Some(1), y: Some(None), z: (Some(1), Some(None)) }, content={
    "x": 1,
    "y": null,
    "z": [[1], [null]],
  })
  json_inspect({ x: Some(1), y: Some(Some(1)), z: (Some(1), Some(Some(1))) }, content={
    "x": 1,
    "y": [1],
    "z": [[1], [[1]]],
  })
}
```



### 容器参数

- `rename_fields` 和 `rename_cases`（仅适用于枚举）分别批量重命名字段（对于枚举和结构体）和枚举构造器为给定格式。可用的参数有：

  - `lowercase`
  - `UPPERCASE`
  - `camelCase`
  - `PascalCase`
  - `snake_case`
  - `SCREAMING_SNAKE_CASE`
  - `kebab-case`
  - `SCREAMING-KEBAB-CASE`

  例如：`rename_fields = "PascalCase"` 用于名为 `my_long_field_name` 的字段将得到 `MyLongFieldName`。

  重命名假定字段的名称为 `snake_case`，结构体/枚举构造器的名称为 `PascalCase`。

- `cases(...)`（仅枚举）控制枚举构造器的布局。

  警告

  这可能在未来会被构造器属性替换。

  例如，对于一个枚举

  ```
  enum E {
    A(...)
    B(...)
  }
  ```

  

  您可以使用 `cases(A(...), B(...))` 控制每个构造器。

  有关详细信息，请参见下面的 [构造器参数](https://docs.moonbitlang.cn/language/derive.html#case-arguments)。

- `fields(...)`（仅结构体）控制结构体字段的布局。

  警告

  这可能在未来会被字段属性替换。

  例如，对于一个结构体

  ```
  struct S {
    x: Int32
    y: Int32
  }
  ```

  

  您可以使用 `fields(x(...), y(...))` 控制每个字段。

  有关详细信息，请参见下面的 [字段参数](https://docs.moonbitlang.cn/language/derive.html#field-arguments)。

### 构造器参数

- `rename = "..."` 重命名此特定构造器，覆盖现有的容器范围重命名指令（如果有的话）。

- `fields(...)` 控制此构造器的负载布局。请注意，目前无法重命名位置字段。

  有关详细信息，请参见下面的 [字段参数](https://docs.moonbitlang.cn/language/derive.html#field-arguments)。

### 字段参数

- `rename = "..."` 重命名此特定字段，覆盖现有的容器范围重命名指令（如果有的话）。

# 错误处理

错误处理一直是我们语言设计的核心。接下来我们将解释 MoonBit 中的错误处理。我们假设您对 MoonBit 有一些了解，如果没有，请查看 [MoonBit 之旅](https://docs.moonbitlang.cn/tutorial/tour.html)。

## 错误类型

在 MoonBit 中，所有的错误类型都可以用 `Error`，一个通用的错误类型，来表示。

但是，`Error` 不能直接构造。必须定义一个具体的错误类型，形式如下：

```
suberror E1 { E1(Int32) }  // 错误类型 E1 具有一个构造器 E1，并带有一个 Int32 负载
suberror E2              // 错误类型 E2 具有一个没有负载的构造器 E2
suberror E3 {            // 错误类型 E3 类似于普通的枚举类型，有三个构造器
  A
  B(Int32, x~ : String)
  C(mut x~ : String, Char, y~ : Bool)
}
```



错误类型可以自动提升为 `Error` 类型，并且可以模式匹配回去：

```
suberror CustomError { CustomError(UInt32) }

test {
  let e : Error = CustomError(42)
  guard! e is CustomError(m)
  assert_eq(m, 42)
}
```



由于 `Error` 类型可以包含多个错误类型，对 `Error` 类型进行模式匹配必须使用通配符 `_` 来匹配所有错误类型。例如：

```
fn f(e : Error) -> Unit {
  match e {
    E2 => println("E2")
    A => println("A")
    B(i, x~) => println("B(\{i}, \{x})")
    _ => println("unknown error")
  }
}
```



`Error` 通常用于不需要具体错误类型的情况，或者简单地用来捕获所有的子错误。

要匹配某个特定子错误类型的所有构造器，请使用通配构造器模式 `Type::_`。该模式可以使用 `as` 捕获类型细化后的子错误值，但仍需最后一个 `_` 分支来覆盖其他子错误类型：

```
fn handle_e3(error : Error) -> Unit {
  match error {
    E3::_ as e => {
      ignore(e)
      println("E3 error")
    }
    _ => println("another error type")
  }
}
```



### Failure

一个内置的错误类型是 `Failure`。

`fail` 是一个便利的函数，它只是一个带有预定义输出模板的构造函数，用于显示错误和源位置。在实践中，`fail!` 总是比 `Failure`更常用。

```
#callsite(autofill(loc))
pub fn[T] fail(msg : String, loc~ : SourceLoc) -> T raise Failure {
  raise Failure("FAILED: \{loc} \{msg}")
}
```



## 抛出错误

关键字 `raise` 被用来中断函数执行并返回一个错误。

函数的类型签名可以用 `raise` 和一个错误类型来表明函数可能抛出一个错误。例如，以下函数 `div` 可能返回一个类型为 `DivError` 的错误：

```
suberror DivError { DivError(String) } derive(Debug)

pub extend DivError with Debug::{to_repr}

fn div(x : Int32, y : Int32) -> Int32 raise DivError {
  if y == 0 {
    raise DivError("division by zero")
  }
  x / y
}
```



`Error` 类型可以在具体的错误类型不重要时使用。为了方便起见，您可以在 `raise` 之后省略错误类型，以表示使用了 `Error` 类型。例如，以下函数签名是等价的：

```
fn f() -> Unit raise {
  ...
}

fn g() -> Unit raise Error {
  let h : () -> Unit raise = fn() raise { fail("fail") }
  ...
}
```



对于在错误类型上是泛型的函数，您可以使用 `Error` 约束来实现。例如：

```
// Result::unwrap_or_error
fn[T, E : Error] unwrap_or_error(result : Result[T, E]) -> T raise E {
  match result {
    Ok(x) => x
    Err(e) => raise e
  }
}
```



对于不抛出错误的函数，您可以在签名中添加 `noraise`。例如：

```
fn add(a : Int32, b : Int32) -> Int32 noraise {
  a + b
}
```



### 错误多态

一个高阶函数在接受另一个函数作为参数时，另一个函数可能会抛出错误，也可能不会抛出错误，这反过来又影响了这个高阶函数的行为。

一个典型的例子是 `Array` 的 `map` 函数：

```
fn[T] map(array : Array[T], f : (T) -> T raise) -> Array[T] raise {
  let mut res = []
  for x in array {
    res.push(f(x))
  }
  res
}
```



然而，这样写会使得 `map` 函数总是有可能抛出错误，这并不是我们想要的。

因此，引入了错误多态。您可以使用 `raise?` 来表示可能会抛出错误，也可能不会抛出错误。

```
fn[T] map_with_polymorphism(
  array : Array[T],
  f : (T) -> T raise?
) -> Array[T] raise? {
  let mut res = []
  for x in array {
    res.push(f(x))
  }
  res
}

fn[T] map_without_error(
  array : Array[T],
  f : (T) -> T noraise,
) -> Array[T] noraise {
  map_with_polymorphism(array, f)
}

fn[T] map_with_error(array : Array[T], f : (T) -> T raise) -> Array[T] raise {
  map_with_polymorphism(array, f)
}
```



`map_with_polymorphism` 的签名将由实际参数推导而来。

## 处理错误

直接调用函数会在出现错误时直接重新抛出错误。例如：

```
fn div_reraise(x : Int32, y : Int32) -> Int32 raise DivError {
  div(x, y) // 如果 `div` 引发错误，则重新抛出错误
}
```



但是，你可能想要处理错误。

### Try ... Catch

你可以使用 `try` 和 `catch` 捕获和处理错误，例如：

```
fn main {
  try div(42, 0) catch {
    DivError(s) => println(s)
  } noraise {
    v => println(v)
  }
}
```



输出

```
除零
```



这里，`try` 用于调用可能引发错误的函数，`catch` 用于匹配和处理捕获的错误。如果没有捕获到错误，`catch` 块将不会执行，而是执行 `noraise` 块。

如果不需要在没有捕获到错误时执行任何操作，则可以省略 `noraise` 块。例如：

```
println(div(42, 0)) catch {
  _ => println("Error")
}
```



当 `try` 的主体是一个简单表达式时，大括号，甚至 `try` 关键字，都可以省略。例如：

```
let a = div(42, 0) catch { _ => 0 }
println(a)
```



### 转换为 Result

您还可以捕获潜在的错误，并将其转换为一等公民的 [`Result`](https://docs.moonbitlang.cn/language/fundamentals.html#option-and-result) 类型：

```
test {
  let res : Result[Int32, DivError] = Ok(div(6, 0) * div(6, 3)) catch {
    error => Err(error)
  }
  match res {
    Err(DivError(message)) => @test.assert_eq(message, "division by zero")
    Ok(_) => fail("expected division to fail")
  }
}
```



### 出错时崩溃

如果发生意外错误，您也可以直接引发崩溃：

```
fn remainder(a : Int32, b : Int32) -> Int32 raise DivError {
  if b == 0 {
    raise DivError("division by zero")
  }
  let div = try! div(a, b)
  a - b * div
}
```



### 错误推导

在 `try` 块中，可能引发多种不同类型的错误。当发生这种情况时，编译器将使用 `Error` 类型作为通用错误类型。因此，处理程序必须使用通配符 `_` 来确保捕获所有错误，并且通过 `e => raise e` 来抛出其他错误。例如：

```
fn f1() -> Unit raise E1 {
  ...
}

fn f2() -> Unit raise E2 {
  ...
}

try {
  f1()
  f2()
} catch {
  E1(_) => ...
  E2 => ...
  e => raise e
}
```



[上一页派生内建特征](https://docs.moonbitlang.cn/language/derive.html)[下一页使用包管理项目](https://docs.moonbitlang.cn/language/packages.html)

# 使用包管理项目

在大规模开发项目时，项目通常需要分解为相互依赖的较小模块单元。更常见的是使用其他人的工作：最典型的是 [core](https://github.com/moonbitlang/core)，MoonBit 的标准库。

## 包和模块

在 MoonBit 中，代码组织的基本单位是包，它由若干源文件和一个包配置文件（`moon.pkg`）组成。包默认为库。包含 `main` 函数的包通过 [`pkgtype(kind: "executable")`](https://docs.moonbitlang.cn/toolchain/moon/package.html#package-type) 声明为可执行程序。

项目对应一个模块，由多个包和一个 `moon.mod` 配置文件组成。对于仍包含 `moon.mod.json` 或 `moon.pkg.json` 的旧项目，请先运行 `moon fmt` 迁移，再使用其他命令。

一个模块由 [`name`](https://docs.moonbitlang.cn/toolchain/moon/module.html#source-directory) 字段标识，通常由两部分组成，用 `/` 分隔：`user-name/project-name`。包由相对于源代码根目录的路径标识，该路径由 [`source`](https://docs.moonbitlang.cn/toolchain/moon/module.html#source-directory) 字段定义。完整标识符为 `user-name/project-name/path-to-pkg`。

使用其他包的内容时，应先在 `moon.mod` 中用 [`import`](https://docs.moonbitlang.cn/toolchain/moon/module.html#dependency-management) 声明模块间的依赖，再在包配置文件（`moon.pkg`）中用 [`import`](https://docs.moonbitlang.cn/toolchain/moon/package.html#import) 字段声明包间的依赖。大多数核心库包也遵循此规则：使用 `@json`、`@test` 等普通核心库别名时，请将对应的 `moonbitlang/core/...` 包加入 `import`，以避免 `core_package_not_imported` 警告。

包的**默认别名**是标识符中 `/` 分隔的最后一部分。可以使用 `@pkg_alias` 访问导入的实体，其中 `pkg_alias` 可以是完整标识符或默认别名。也可以使用 [`import`](https://docs.moonbitlang.cn/toolchain/moon/package.html#import) 字段定义自定义别名。

在 `moon.pkg` 中，自定义别名写法为：

```
import {
  "moonbit-community/language/packages/pkgA",
  "moonbit-community/language/packages/pkgC" @c,
  "moonbitlang/core/builtin",
}
```



pkgB/top.mbt

```
///|
pub fn add1(x : Int32) -> Int32 {
  @moonbitlang/core/builtin.Add::add(0, @c.incr(@pkgA.incr(x)))
}
```



### Prelude 与内建名称

如果省略 `@pkg.`，MoonBit 会在当前包和 prelude 中解析未限定名称。因此，本地定义的同名标识符会遮蔽 prelude 中的定义。

```
fn println(msg : String) -> String {
  "log: \{msg}"
}

///|
fn shadowed_println() -> String {
  println("hello")
}

///|
fn builtin_answer() -> Int32 {
  let answer : Int32 = 42
  answer
}
```



`prelude` is a special package: it is available by default, and names exposed through it participate in normal unqualified name resolution without an explicit `import`.

编译器内建项是另一类概念。像 `Int32` 这样的类型是语言本身内建的，不是从任何包中导入进来的，因此不存在 `@builtin.Int32`。`String`、`Bool` 和 `Unit` 等其他由编译器识别的名称也是如此。

### 内部包

你可以定义只对某些包可用的内部包。

在 `a/b/c/internal/x/y/z` 中的代码只对包 `a/b/c` 和 `a/b/c/**` 可用。

### 使用

你可以使用 `using` 语法导入在另一个包中定义的符号。

pkgC/top.mbt

```
///|
pub using @pkgA {incr, trait Trait, type Type}
```



通过使用 `pub` 修饰符，它被视为重新导出。



## 访问控制

MoonBit 具有全面的访问控制系统，管理代码的哪些部分可以从其他包访问。此系统有助于维护封装、信息隐藏和清晰的 API 边界。可见性修饰符适用于函数、变量、类型和特征，允许对代码如何被他人使用进行细粒度控制。

### 函数

默认情况下，所有函数定义和变量绑定对其他包是 *不可见* 的。可以在顶层 `let`/`fn` 前使用 `pub` 修饰符使其公开。

### 别名

默认情况下，[函数别名](https://docs.moonbitlang.cn/language/fundamentals.html#type-alias) 和 [方法别名](https://docs.moonbitlang.cn/language/methods.html#alias-methods-as-functions) 遵循原始定义的可见性，而 [类型别名](https://docs.moonbitlang.cn/language/fundamentals.html#type-alias)、[using](https://docs.moonbitlang.cn/language/packages.html#using) 对其他包是 *不可见* 的。

可以在定义之前添加 `pub` 修饰符，或在注释中填写 `visibility` 字段。

### 类型

MoonBit 中有四种不同的类型可见性：

- 私有类型，使用 `priv` 声明，对外部世界完全不可见

- 抽象类型：这是类型的默认可见性。

  只有抽象类型的名称在外部可见，该类型的内部表示是隐藏的。将抽象类型默认设置为隐藏是设计选择，旨在鼓励封装和信息隐藏。

- 使用 `const` 声明的常量

  只读类型，使用 `pub` 声明。只读类型的内部表示对外部可见，但用户只能从外部读取这些类型的值，不允许构造和修改

- 完全公开的类型，使用 `pub(all)` 声明。

  完全公开类型，使用 `pub(all)` 声明。外部世界可以自由构造、修改和读取这些类型的值

除了类型本身的可见性外，公开的结构体的字段可以用 `priv` 注释，这将对外部世界完全隐藏字段。请注意，具有私有字段的 `struct` 不能直接在外部构造，但可以使用函数式 `struct` 更新语法更新公开字段。

只读类型是一个非常有用的功能，受到 OCaml 中 [私有类型](https://ocaml.org/manual/5.3/privatetypes.html) 的启发。简而言之，`pub` 类型的值可以通过模式匹配和点语法解构，但不能在其他包中构造或修改。请注意，在定义 `pub` 类型的同一包中没有限制。

备注

在定义 `pub` 类型的同一包中没有任何限制。

```
// Package A
pub struct RO {
  field: Int32
}
test {
  let r = { field: 4 }       // 可以
  let r = { ..r, field: 8 }  // 可以
}

// Package B
fn println(r : RO) -> Unit {
  println("{ field: ")
  println(r.field)  // 可以
  println(" }")
}
test {
  let r : RO = { field: 4 }  // 错误：不能创建公开只读类型 RO 的值！
  let r = { ..r, field: 8 }  // 错误：不能修改公开只读字段！
}
```



MoonBit 中的访问控制遵循一个原则，即公开的类型、函数或变量不能以私有类型定义。这是因为私有类型可能无法在使用公开的实体的所有地方访问。MoonBit 包含了健全性检查，以防止违反这一原则的用例发生。

```
pub(all) type T1
pub(all) type T2
priv type T3

pub(all) struct S {
  x: T1  // 可以
  y: T2  // 可以
  z: T3  // 错误：公开字段使用了私有类型 `T3`！
}

// 错误：公开函数使用了私有类型 `T3`！
pub fn f1(_x: T3) -> T1 { ... }
// 错误：公开函数的返回值使用了私有类型 `T3`！
pub fn f2(_x: T1) -> T3 { ... }
// 可以
pub fn f3(_x: T1) -> T1 { ... }

pub let a: T3 = { ... } // 错误：公开变量的类型是私有类型 `T3`！
```



### 特征

特征有四种可见性，就像 `struct` 和 `enum`：私有、抽象、只读和完全公开。

- 私有类型，使用 `priv` 声明，对外部世界完全不可见
- 特征默认是抽象的。只有特征类型的名称对外部可见，特征的方法被隐藏
- 只读特征，使用 `pub trait` 声明，它们的方法可以从外部调用，但只有当前包可以为只读特征添加新实现
- 完全公开的特征，使用 `pub(open) trait` 声明，在外部包也可以增加实现，其方法可以自由使用

抽象特征和只读特征是封闭的，因为只有定义特征的包才能实现它们。在包外实现封闭（抽象或只读）特征会导致编译器错误。

#### 特征的实现

实现本身有独立的可见性，就像函数一样。除非实现是 `pub`，否则在当前包之外，类型不会被认为已经实现了特征。

为了使特征系统一致（即每个 `Type: Trait` 对都有全局唯一的实现），并防止第三方包意外地修改现有程序的行为，MoonBit 对谁可以定义方法/实现类型的特征采用了以下限制：

- **只有定义类型的包才能为其定义方法**。因此，不能为内建和外部类型定义新方法或覆盖旧方法。
  - 这条规则有一个例外：[本地方法](https://docs.moonbitlang.cn/language/methods.html#local-method)。不过，本地方法永远是私有的，因此它们不会破坏 MoonBit 类型系统的一致性。
- **只有类型的包或特征的包才能定义实现**。例如，只有 `@pkg1` 和 `@pkg2` 允许编写 `impl @pkg1.Trait for @pkg2.Type`。

上述第二条规则允许通过定义新特征并实现它来为外部类型添加新功能。这使 MoonBit 的特征和方法系统灵活，同时享有良好的一致性属性。

警告

目前，空特征会自动实现。

以下是抽象特征的示例：

```
trait Number {
 op_add(Self, Self) -> Self
 op_sub(Self, Self) -> Self
}

fn[N : Number] add(x : N, y: N) -> N {
  Number::op_add(x, y)
}

fn[N : Number] sub(x : N, y: N) -> N {
  Number::op_sub(x, y)
}

impl Number for Int32 with op_add(x, y) { x + y }
impl Number for Int32 with op_sub(x, y) { x - y }

impl Number for Double with op_add(x, y) { x + y }
impl Number for Double with op_sub(x, y) { x - y }
```



从包外，用户只能看到以下内容：

```
trait Number

fn[N : Number] op_add(x : N, y : N) -> N
fn[N : Number] op_sub(x : N, y : N) -> N

impl Number for Int32
impl Number for Double
```



`Number` 的作者可以利用只有 `Int32` 和 `Double` 可以实现 `Number` 这一事实，因为在外部不允许新的实现。

## 虚拟包

警告

虚拟包是一个实验性功能。可能存在错误和未定义的行为。

你可以定义虚拟包，它作为一个接口。它们可以在构建时被特定的实现替换。目前，虚拟包只能包含普通函数。

虚拟包在保持代码不变的情况下，可以在不同的实现之间进行切换。

### 定义一个虚拟包

你需要声明它是一个虚拟包，并在 MoonBit 接口文件中定义其接口。

在 `moon.pkg` 中，你需要添加字段 [`virtual`](https://docs.moonbitlang.cn/toolchain/moon/package.html#declarations) :

```
virtual(has_default: true)
```



The `has-default` 表示虚拟包是否有默认实现。

在包内，你需要添加一个接口文件 `pkg.mbti`：

/src/packages/virtual/pkg.mbti

```
package "moonbit-community/language/packages/virtual"

fn log(String) -> Unit
```



接口文件的第一行需要是 `package "full-package-name"`。接下来是声明。[访问控制](https://docs.moonbitlang.cn/language/packages.html#access-control) 的 `pub` 关键字和函数参数名称应该省略。

提示

如果你不确定如何定义接口，可以创建一个普通包，使用 [TODO 语法](https://docs.moonbitlang.cn/language/fundamentals.html#todo-syntax) 定义所需的函数，并使用 `moon info` 帮助你生成接口。

### 实现虚拟包

一个虚拟包可以有一个默认实现。通过将 [`virtual.has-default`](https://docs.moonbitlang.cn/toolchain/moon/package.html#declarations) 设置为 `true`，你可以在同一包内照常实现代码。

/src/packages/virtual/top.mbt

```
///|
pub fn log(s : String) -> Unit {
  println(s)
}
```



虚拟包也可以由第三方实现。通过将 [`implements`](https://docs.moonbitlang.cn/toolchain/moon/package.html#implementations) 定义为目标包的完整名称，编译器可以警告你关于缺失的实现或不匹配的实现。

```
virtual(implement: "moonbit-community/language/packages/virtual")
```



/src/packages/implement/top.mbt

```
///|
pub fn log(string : String) -> Unit {
  ignore(string)
}
```



### 使用虚拟包

要使用虚拟包，与其他包一样：在你想要使用它的包中定义 [`import`](https://docs.moonbitlang.cn/toolchain/moon/package.html#import) 字段。

### 覆盖虚拟包

如果虚拟包有一个默认实现，并且是你想要的，则不需要额外的配置。

否则，你可以通过提供一个实现数组来定义 [`overrides`](https://docs.moonbitlang.cn/toolchain/moon/package.html#overriding-implementations) 字段，指定你想要使用的实现。

/src/packages/use_implement/moon.pkg

```
import {
  "moonbit-community/language/packages/virtual",
}

pkgtype(kind: "executable")

options(
  overrides: [ "moonbit-community/language/packages/implement" ],
)
```



在使用实体时，你应该引用虚拟包。

/src/packages/use_implement/top.mbt

```
///|
fn main {
  @virtual.log("Hello")
}
```

# 编写测试

测试对于提高程序的质量和可维护性很重要。它们验证程序的行为，也作为规范，以避免随时间的推移出现退步。

MoonBit 提供测试支持，使编写测试更加简单和容易。

## 测试块

MoonBit 提供测试代码块，用于编写内联测试用例。例如：

```
test "test_name" {
  assert_eq(1 + 1, 2)
  assert_eq(2 + 2, 4)
  debug_inspect([1, 2, 3], content="[1, 2, 3]")
}
```



测试代码块本质上是一个类型为 `() -> Unit raise Error` 的函数：它返回 `Unit`，并可能抛出 [`Error`](https://docs.moonbitlang.cn/language/error-handling.html#error-types)。它在执行 `moon test` 期间被调用，并通过构建系统输出测试报告。`assert_eq` 函数来自标准库；如果断言失败，它会打印错误消息并终止测试。字符串 `"test_name"` 用于标识测试用例，是可选的。

由 `moon test` 启动的测试以模块根目录作为当前工作目录。测试中的相对路径应从模块根目录解析，而不是从包目录或测试文件所在目录解析。

如果测试名称以 `"panic"` 开头，表示测试的预期行为是触发 panic，只有在触发 panic 时测试才会通过。例如：

```
test "panic_test" {
  let _ : Int32 = Option::None.unwrap()
}
```



## 快照测试

在指定预期值时，编写测试可能会很繁琐。因此，MoonBit 提供了三种快照测试。所有这些都可以使用 `moon test --update` 自动插入或更新。

### 快照 `Show`

我们可以使用 `inspect(x, content="x")` 来检查实现了 `Show` 特征的任何内容。正如我们之前提到的，`Show` 是一个可以派生的内建特征，提供了 `to_string`来打印数据结构的内容。标记参数 `content` 可以省略，因为 `moon test --update` 会自动插入：

```
struct X {
  x : Int32
} derive(Debug)

pub extend X with Debug::{to_repr}

test "show snapshot test" {
  debug_inspect({ x: 10 }, content="{ x: 10 }")
}
```



### 快照 `JSON`

派生的 `Show` 特征的问题是它不能对输出进行格式化，导致输出非常长。

解决方案是使用 `@json.inspect(x, content=x)`。其好处是生成的内容是一个 JSON 结构，在格式化后更易读。

```
enum Rec {
  End
  Really_long_name_that_is_difficult_to_read(Rec)
} derive(Debug, ToJson)

pub extend Rec with Debug::{to_repr}

pub extend Rec with ToJson::{to_json}

test "json snapshot test" {
  let r = Really_long_name_that_is_difficult_to_read(
    Really_long_name_that_is_difficult_to_read(
      Really_long_name_that_is_difficult_to_read(End),
    ),
  )
  debug_inspect(
    r,
    content="Really_long_name_that_is_difficult_to_read(Really_long_name_that_is_difficult_to_read(Really_long_name_that_is_difficult_to_read(End)))",
  )
  json_inspect(r, content=[
    "Really_long_name_that_is_difficult_to_read",
    [
      "Really_long_name_that_is_difficult_to_read",
      ["Really_long_name_that_is_difficult_to_read", "End"],
    ],
  ])
}
```



也可以实现自定义 `ToJson` 来保留必要的信息。

### 快照任何内容

有时我们不仅要记录一个数据结构，还要记录整个过程的输出。

可以使用完整的快照测试使用 `@test.T::write` 和 `@test.T::writeln` 记录任何内容：

```
test "record anything" (t : @test.Test) {
  t.write("Hello, world!")
  t.writeln(" And hello, MoonBit!")
  t.snapshot(filename="record_anything.txt")
}
```



这将在该包的 `__snapshot__` 下创建一个具有给定文件名的文件：

```
Hello, world! And hello, MoonBit!
```



这也可以用于测试应用程序的输出，无论是创建图像、视频还是一些自定义数据。

请注意，`@test.T::snapshot` 应该在测试块的末尾使用，因为它总是引发异常。

## 基于性质的测试

基于示例的测试检查特定输入，而基于性质的测试描述大量生成的输入都应满足的关系。在普通的 `test` 块中使用标准库的 `quickcheck` 包即可，无需添加额外的模块依赖。对于 `_test.mbt` 文件中的示例，在 `moon.pkg` 中添加以下导入：

```
import {
  "moonbitlang/core/quickcheck",
} for "test"
```



### 检查性质

加零应当保持整数不变：

```
test "adding zero preserves an integer" {
  @quickcheck.check((x : Int32) => x + 0 == x, count=100, seed=2026)
}
```



使用 `moon test` 运行这个测试。`check` 会生成输入，并逐一调用性质函数。返回 `true` 表示该用例通过；返回 `false` 或抛出错误会使 `check` 报告失败。这里，`count` 指定检查 100 个用例，`seed` 使运行可以复现。生成的 `Int32` 值并不限于较小的数，也可能接近该类型的极限。

输入类型必须实现 `Arbitrary` 来生成值、`Shrink` 来简化失败的输入，以及 `Debug` 来显示这些输入。常见类型（包括 `Int32`）已提供这些实现。性质函数应保持确定性，并避免修改输入。

### 理解反例

那么加一呢？`x + 1 > x` 对数学中的整数成立，但对 `Int32` 也成立吗？0、1、100 等较小的示例都会通过。下面使用 `report` 寻找反例。它返回结果而不是抛出测试失败，因此可以用快照记录失败报告，同时让演示本身保持为通过的测试：

```
test "adding one does not always increase an integer" {
  let report = @quickcheck.report(
    (x : Int32) => x + 1 > x,
    count=100,
    seed=2026,
  )
  debug_inspect(
    report,
    content=(
      #|Falsified(
      #|  counterexample=2147483647,
      #|  tests=99,
      #|  size=98,
      #|  shrinks=0,
      #|  shrink_attempts=31,
      #|)
    ),
  )
}
```



`Falsified` 表示性质函数返回了 `false`。反例是 `2147483647`，即最大的 `Int32`。加一会溢出并回绕到 `-2147483648`，所以结果变小了，而非变大。这是对固定宽度整数运算的错误假设，不是加法实现的缺陷。

QuickCheck 还会尝试仍然导致失败的更简单输入，这个过程称为缩减（shrinking）。这里 `shrinks=0`：没有更小的输入能保留这个失败，因为只有最大的 `Int32` 不满足该性质。可选参数 `max_shrinks` 限制检查的候选输入数量；一般而言，缩减并不保证找到最小的反例。如果性质不成立时应当让测试套件失败，请使用 `check` 而不是 `report`。

### 保留回归测试

要复现一次运行，需要保持种子、设置、性质函数以及工具链和库版本不变。不同版本生成的用例和缩减结果可能不同。一旦反例揭示了缺陷或错误的预期，就应将该具体输入保留在基于示例的测试中，并写明正确的预期行为：

```
test "adding one at the Int32 boundary" {
  let x : Int32 = 2147483647
  assert_eq(x + 1, -2147483648)
  assert_eq(x.to_int64() + 1, 2147483648L)
}
```



第二个断言在加一**之前**转换为 `Int64`，其范围足以容纳这次计算的结果。如果在 `Int32` 加法完成后再转换结果就太晚了：溢出已经发生。

两种测试都应保留：回归测试始终检查已发现的用例，而性质测试可以通过其他种子和设置探索更多输入。生成的用例全部通过，并不能证明性质对所有输入都成立。

关于自定义生成器及更多选择有效性质的方法，请参阅 [MoonBit 中基于性质的测试](https://www.moonbitlang.com/blog/property-based-testing-moonbit)。

## 黑盒测试和白盒测试

在开发库时，验证用户是否可以正确使用它是很重要的。例如，可能会忘记使类型或函数公开。这就是为什么 MoonBit 提供了黑盒测试，允许开发人员了解其他人的感受。

- 能够访问包中所有成员的测试称为白盒测试，因为我们可以看到一切。这样的测试可以内联定义，也可以在文件中定义，文件名以 `_wbtest.mbt` 结尾。
- 只能访问包中公开成员的测试称为黑盒测试。这样的测试需要在文件中定义，文件名以 `_test.mbt` 结尾。

The WhiteBox test files (`_wbtest.mbt`) imports the packages defined in the `import` and `wbtest-import` sections of the package configuration (`moon.pkg`, or legacy `moon.pkg.json`).

The BlackBox test files (`_test.mbt`) imports the current package and the packages defined in the `import` and `test-import` sections of the package configuration (`moon.pkg`, or legacy `moon.pkg.json`).

# 编写基准测试

基准是一种衡量代码性能的方法。它们可以用于比较不同的实现质量，或跟踪随时间变化的性能。

## 使用测试块进行基准测试

对一个函数进行基准测试的最简单的方法是使用带有 `@bench.T` 参数的测试块。它有一个方法 `@bench.T::bench`，该方法接受一个类型为 `() -> Unit` 的函数，并自动确定合适的迭代次数然后运行该函数多次。测量和统计分析将在 `moon` 中进行，并在控制台输出中显示。

```
fn fib(n : Int32) -> Int32 {
  if n < 2 {
    return n
  }
  return fib(n - 1) + fib(n - 2)
}

test (b : @bench.T) {
  b.bench(fn() { b.keep(fib(20)) })
}
```



输出如下所示（仅供参考）：

```
time (mean ± σ)         range (min … max) 
  21.67 µs ±   0.54 µs    21.28 µs …  23.14 µs  in 10 ×   4619 runs
```



该函数执行了 `10 × 4619` 次。第二个数字是由基准工具自动确定的。它会增加迭代次数，直到测量时间足够长，以获得准确的计时。第一个数字可以通过向 `@bench.T::bench` 传递命名参数 `count` 来调整。

```
test (b : @bench.T) {
  b.bench(fn() { b.keep(fib(20)) }, count=20)
}
```



`@bench.T::keep` 是一个重要的辅助函数，它可以防止你的计算被优化掉并完全跳过。如果你正在基准测试一个纯函数，请确保使用这个函数以避免潜在的优化。然而，编译器仍然有可能提前计算并将计算替换为常量。

## 批量基准测试

基准测试的一个常见场景是比较同一函数的两个或多个实现。在这种情况下，你可能想要在一个块中批量测试它们，以便于比较。`@bench.T::bench` 方法的 `name` 参数可以用来标识测试块内的基准测试。

```
fn fast_fib(n : Int32) -> Int32 {
  if n < 2 {
    return n
  } else {
    let mut a = 0
    let mut b = 1
    for i = 2; i <= n; i = i + 1 {
      let t = a + b
      a = b
      b = t
    }
    b
  }
}

test (b : @bench.T) {
  b.bench(name="naive_fib", fn() { b.keep(fib(20)) })
  b.bench(name="fast_fib", fn() { b.keep(fast_fib(20)) })
}
```



现在你可以通过查看输出，来评估哪个实现更快：

```
name      time (mean ± σ)         range (min … max) 
naive_fib   21.01 µs ±   0.21 µs    20.76 µs …  21.32 µs  in 10 ×   4632 runs
fast_fib     0.02 µs ±   0.00 µs     0.02 µs …   0.02 µs  in 10 × 100000 runs
```



## 基准统计的原始数据

有时用户可能希望获取原始基准统计数据以进行进一步的分析。有一个函数 `@bench.single_bench` 返回一个抽象的 `Summary` 类型，用户可以将其序列化为 JSON 格式。我们不保证 `Summary` 类型内部字段的稳定性。

在使用 `@bench.single_bench` 时，用户必须确保计算没有被优化掉。此时没有独立的 `keep` 函数可用；之前介绍过的 `keep` 是 `@bench.T` 的一个方法。

```
fn collect_bench() -> Unit {
  let mut saved = 0
  let summary : @bench.Summary = @bench.single_bench(name="fib", fn() {
    saved = fib(20)
  })
  println(saved)
  println(@json.to_json(summary).stringify(escape_slash=true, indent=4))
}
```



输出可能如下所示：

```
6765
{
    "name": "fib",
    "sum": 217.22039973878972,
    "min": 21.62009230518067,
    "max": 21.87286402916848,
    "mean": 21.72203997387897,
    "median": 21.70412048323901,
    "var": 0.007197724461032505,
    "std_dev": 0.08483940394081341,
    "std_dev_pct": 0.39056830777787843,
    "median_abs_dev": 0.08189815918589166,
    "median_abs_dev_pct": 0.3773392211360855,
    "quartiles": [
        21.669052078798433,
        21.70412048323901,
        21.76141434479756
    ],
    "iqr": 0.09236226599912811,
    "batch_size": 4594,
    "runs": 10
}
```



时间单位均为微秒。

# 注释与文档

## 注释

在代码内部使用 `//` 编写普通注释：

```
// Explain why this branch exists.
let retries = 3
```



你也会经常在顶层代码块开头看到 `///|`。它是一条空的文档注释行，用来显式分隔顶层条目。这对于当前的文档工具链很重要，也能为未来的缓存和其他工具用途保留清晰的顶层块边界。实际使用中，`///|` 不仅适用于文档源码，在普通的 MoonBit 代码里也很有用。

## 文档注释

文档注释使用 `///`，逐行写在 `fn`、`let`、`enum`、`struct`、`type` 等顶层条目前面。文档注释内容使用 Markdown 编写。

```
/// 返回一个新数组，其中元素被反转。
fn[T] reverse(xs : Array[T]) -> Array[T] {
  ...
}
```



文档注释中的 Markdown 代码块如果标记为 `mbt check`，就会被视作文档测试；`moon check` 和 `moon test` 会自动检查并运行这些测试，从而保证文档注释中的示例始终是最新的。需要测试块时，请将代码包在 `test { .. }` 中：

```
/// Increment an integer by one,
///
/// Example:
/// ```mbt check
/// test {
///   inspect(@misc.incr(41), content="42")
/// }
/// ```
pub fn incr(x : Int32) -> Int32 {
  x + 1
}
```



如果想要阻止一段代码被当作文档测试，只需要在它的 markdown 代码块上标记一个 `mbt check` 以外的语言名字：

```
/// `c_incr(x)` 等价于下面的 C 代码：
/// ```c
/// x++
/// ```
pub fn c_incr(x : Ref[Int32]) -> Int32 {
  let old = x.val
  x.val += 1
  old
}
```



目前，文档测试都是 [黑盒测试](https://docs.moonbitlang.cn/language/tests.html#blackbox-tests-and-whitebox-tests)。所以私有定义目前不能有文档测试。

## 文学化 `.mbt.md` 文件

MoonBit 也支持以 `.mbt.md` 结尾的文学化 Markdown 文件。这些文件既可以作为包内的可检查文档，也可以作为 `moon check` 和 `moon test` 的独立单文件输入。

对于独立文件，运行：

```
moon check README.mbt.md
moon test README.mbt.md
```



在项目内部，请继续使用包级别的 `moon check` 和 `moon test` 命令。

代码块的语言标记决定了每个代码块会如何处理：

- `mbt`：会编译其中的 MoonBit 代码，但不会创建测试入口。
- `mbt check`：MoonBit 文档测试代码。需要断言时，请在代码块内部使用 `test { .. }` 或 `async test`。
- `mbt nocheck`：展示 MoonBit 代码，但不编译也不测试。
- `moonbit`：普通的文档展示代码块，不会被编译或测试。

例如：

```
​```mbt nocheck
///|
fn helper() -> Int32 {
  42
}
​```

​```mbt check
///|
test "forty two" {
  inspect(40 + 2, content="42")
}
​```

​```mbt nocheck
///|
fn native_only() -> Unit {
  ...
}
​```
```



独立的 `.mbt.md` 文件也可以声明 front matter 来指定导入或目标后端：

```
---
moonbit:
  import:
    - path: moonbitlang/core/ref
      alias: ref
  backend:
    native
---

​```mbt check
fn answer() -> Int32 {
  let cell = @ref.Ref::{ val: 41 }
  cell.val + 1
}

///|
test "answer" {
  inspect(answer(), content="42")
}
​```
```



当你想显式指定该文件可以直接导入哪些包时，使用 `moonbit.import`。当你只想声明模块依赖并让 Moon 自动合成导入时，使用 `moonbit.deps`。

# 属性

Attributes are annotations placed before structures in source code. They take the form `#attribute(...)`. An attribute occupies the entire line, and newlines are not allowed within it. Attributes do not normally affect the meaning of programs. Unused attributes will be reported as warnings.

属性的语法如下所示：

```
attribute ::= '#' attribute-name
            | '#' attribute-name '(' attribute-arguments ')'

attribute-name ::= LIDENT | LIDENT '.' LIDENT

attribute-arguments ::= attribute-argument (',' attribute-argument )*

attribute-argument ::= expr | LIDENT '=' expr

expr ::= LIDENT | UIDENT | STRING | 'true' | 'false'
       | LIDENT '.' LIDENT
       | LIDENT '(' attribute-arguments ')'
       | LIDENT '.' LIDENT '(' attribute-arguments ')'
```



属性有两种类别：内建属性和用户自定义属性。例如：

```
#deprecated("message")
#custom.attribute(key="value", flag=true)
```



第一个属性是一个内建的属性，在属性名中，它没有命名空间前缀。内建属性会被 MoonBit 编译器检查，并且有特殊的含义。

第二个属性是用户自定义属性，它的名字中包含命名空间前缀。用户自定义属性会被编译器忽略，通过解析源码，它能够被外部的工具使用。

备注

MoonBit 在设计上有意不支持运行时反射。运行时反射容易被滥用，使得工具链（例如编译器）在编译时不可能捕获到错误，让代码的维护变得更困难。它也会对性能优化产生负面影响。

我们更倾向于使用编译时的代码生成，维持静态类型分析和性能上的优势（代码生成也需要节约地使用，避免不必要的复杂性）。

## `deprecated` 属性

The `#deprecated` attribute is used to mark an API as deprecated. MoonBit emits a warning when the deprecated API is used, and if the API is listed in completion, it will be shown with a strikethrough style. For example:

```
#deprecated
pub fn foo() -> Unit {
  ...
}

#deprecated("Use Bar2 instead")
pub(all) enum Bar {
  Ctor1
  Ctor2
}
```



`#deprecated` 属性能够在如下上下文中使用：

- 顶层的值声明（包括 `fn`，`let` 和 `const`）
- 顶层的类型声明（包括 `type`，`struct` 和 `enum`）
- 特征声明
- 特征的默认实现
- `extend` 声明

常见形式包括：

- `#deprecated`

  将这个项目标记成弃用的，并使用默认的警告信息。

- `#deprecated("使用 new_function 代替")`

  将 API 标记为弃用，并自定义一个警告信息。每当这个弃用的 API 被使用时，自定义信息将会显示在警告中。

- `#deprecated("使用 new_function 代替", skip_current_package=true)`

  将 API 标记为弃用的同时自定义警告信息，但是当 API 在同一个包内使用时不触发警告。

- `#deprecated(skip_current_package=true)`

  Marks the item as deprecated with a default warning message, but skips emitting warnings within the same package. When both a message and `skip_current_package` are present, either argument order is accepted.

## Alert Attribute

`#alert` 属性会为 API 附加一个类别和一条消息。当代码使用该 API 时，MoonBit 会发出 alert 警告。

```
#alert(unsafe, "This function is unsafe.")
fn[A] alert_unsafe_get(arr : Array[A], index : Int32) -> A {
  arr[index]
}
```



第一个参数是 alert 类别，第二个参数是展示给用户的消息。该警告可以通过 `alert`、`alert_unsafe` 等警告名称配置。

For more detail, see [alert warning](https://docs.moonbitlang.cn/toolchain/moon/package.html#alert-warning).

## `alias` 属性

`alias` 属性用于重载一个和索引操作相关的运算符，或者为一个顶层函数与变量创建别名。它有两种形式：

- `#alias("op")`: `op` 是下面其中一个字符串，表示对应的索引操作：
  - `_[_]`：数组索引操作符
  - `_[_]=_`：数组索引赋值操作符
  - `_[_:_]`：op_as_view 操作符
- `#alias(id)`: 其中 `id` 是一个代表别名的标识符

所有形式都支持额外的参数：

- `visibility="modifier"`

  一个带标签的参数，用于改变别名的可见性。`modifier` 可以是 `pub` 或者 `priv`，如果没有声明，别名会和原始的函数或者变量有一样的可见性。

- `deprecated` 或者 `deprecated="message"`

  将别名标记为弃用的。如果提供了 `message` 信息，当别名被使用时，信息会被一起显示在警告中。

`#alias` 不能用于 `declare fn` 或 `declare let`。请将该属性放在对应的定义上。

若要在基于声明的接口中暴露别名，请用 `declare fn` 或 `declare let` 单独声明别名。声明指定名称及其类型，但不要求这些名称之间存在别名关系。实现使用 `#alias` 还是分别提供定义，属于实现细节。

```
///|
declare pub fn new_name() -> Int32

///|
declare pub fn old_name() -> Int32

///|
#alias(old_name)
pub fn new_name() -> Int32 {
  42
}
```



To graceful migration from old API to new API, you can rename the old API directly, and create an alias with the old name, mark it as deprecated. For example:

```
#alias(old_name, deprecated)
fn new_name() -> Unit {
  ()
}
```



## `label_migration` 属性

The `#label_migration` attribute is used to help you safely evolve your API by warning users during the transition period.

它有如下三种形式：

- `#label_migration(id, fill=true, msg="message")`

  The `fill` argument is used when you want to refactor an optional parameter. You can use `fill=true` when you want to eventually make an optional parameter required. You can use `fill=false` when you want to eventually remove an optional parameter.

  `msg`参数是一个字符串，用于提供额外的信息，告诉使用者关于可见性的变更。

  ```
  #label_migration(x, fill=true)
  #label_migration(y, fill=false)
  fn label_migration_fill(x~ : Int32 = 0, y~ : Int32 = 1) -> Int32 {
    x + y
  }
  ```

  

- `#label_migration(id, allow_positional=true, msg="message")`

  The `allow_positional` argument is used when you want a labelled parameter to be used without its label being provided. When the parameter is used positionally (without a label), the compiler reports a warning. This is useful when you want to change a positional parameter to a labelled parameter without breaking the downstream code.

  `msg`参数是一个字符串，用于提供额外的信息，告诉使用者关于可见性的变更。

  ```
  #label_migration(x, allow_positional=true)
  fn label_migration_allow_positional(x~ : Int32) -> Int32 {
    x
  }
  ```

  

- `#label_migration(id, alias=new_id, msg="message")`

  The alias argument allows you to provide an alternative name to a labelled parameter. This is useful when renaming a parameter to maintain backward compatibility. If a warning message is provided, the compiler warns when using the alias; otherwise, the alias can be used without warnings.

  `msg`参数是一个字符串，用于提供额外的信息，告诉使用者关于可见性的变更。

  ```
  #label_migration(x, alias=xx)
  #label_migration(x, alias=y, msg="warning")
  fn label_migration_alias(x~ : Int32) -> Int32 {
    x
  }
  ```

  

## `visibility` 属性

备注

这里的文档不涉及访问控制。关于如何使用 `pub`、`pub(all)` 和 `priv`，见[访问控制](https://docs.moonbitlang.cn/language/packages.html#id1)。

The `#visibility` attribute is similar to the `#deprecated` attribute, but it is used to hint that a type will change its visibility in the future. For outside usages, if the usage will be invalidated by the visibility change in future, a warning will be emitted.

```
// in @util package
#visibility(change_to="readonly", "Point will be readonly in the future.")
pub(all) struct Point {
  x : Int32
  y : Int32
}

#visibility(change_to="abstract", "Use new_text and new_binary instead.")
pub(all) enum Resource {
  Text(String)
  Binary(Bytes)
}

pub fn new_text(str : String) -> Resource {
  ...
}

pub fn new_binary(bytes : Bytes) -> Resource {
  ...
}

// in another package
fn main {
  let p = Point::{ x: 1, y: 2 } // warning
  let { x, y } = p // ok
  println(p.x) // ok
  match Resource::Text("") { // warning
    Text(s) => ... // waning
    Binary(b) => ... // warning
  }
}
```



The `#visibility` attribute takes a required `change_to` argument and an optional `message` argument.

- `change_to`参数是一个表示该类型新的可见性的字符串，它可以是`"abstract"`或者`"readonly"`

  | `"change_to"`的值 | 将要禁止的使用                                               |
  | ----------------- | ------------------------------------------------------------ |
  | `"readonly"`      | 创建该类型的实例，或者变更实例的字段的值。                   |
  | `"abstract"`      | 创建该类型的实例、变更实例的字段的值、对它的实例进行模式匹配或者访问实例的字段。 |

- The optional `message` argument is a string that provides additional information about the visibility change.

## 非穷尽枚举属性

`#non_exhaustive` 属性用于标记定义包可能在未来版本中添加构造器的 `enum`。它只能用于枚举声明。

```
///|
#non_exhaustive
pub(all) enum Response {
  Ok(String)
  NotFound
}
```



定义包之外的代码必须使用 `Type::..` 模式处理未来可能出现的构造器：

```
///|
pub fn render(response : @base.Response) -> String {
  match response {
    @base.Ok(body) => body
    @base.NotFound => "not found"
    @base.Response::.. => "unsupported response"
  }
}
```



`Type::..` 模式专用于前向兼容。它不能替代枚举中当前已知的构造器：这些构造器必须在该模式之前显式匹配。处理定义包未来版本新增的构造器时，通配符模式（`_`）不能替代 `Type::..`。

因此，只要下游匹配使用了 `Type::..`，为 `#non_exhaustive` 枚举新增构造器就是兼容变更。

## `internal` 属性

The `#internal` attribute is used to mark a function, type, or trait as internal. Any usage of the internal function or type in other modules will emit an alert warning.

```
#internal(unsafe, "This is an unsafe function")
fn[A] internal_unsafe_get(arr : Array[A], index : Int32) -> A {
  arr[index]
}
```



The internal attribute takes a required `category` argument and an optional `message` argument. `category` is a identifier that indicates the category of the alert, and `message` is a string that provides additional message for the alert.

`alert` 警告可以通过设置 `moon.pkg` 中的 `warnings` 字段关闭。更多细节见 [alert 警告](https://docs.moonbitlang.cn/toolchain/moon/package.html#alert-warning)。

## Doc Hidden Attribute

`#doc(hidden)` 属性会在生成的文档中隐藏 API。

```
#doc(hidden)
pub fn hidden_helper() -> Unit {
  ()
}
```



它适用于必须继续对代码可用、但不应作为文档化 API 表面展示的公开声明。

## `warnings` 属性

The `#warnings` attribute is used to configure warning settings for a specific top-level declaration. It can enable, disable or treat an enabled warning as error for specific warnings in that declaration.

The argument is a string that specifies the warning list. It can contain multiple warning names, each prefixed with a sign:

```
#warnings("-unused_value")
fn warnings_example() -> Unit {
  let x = 42
}
```



这些前缀有以下含义：

- `+warning_name`: 启用这个警告
- `-warning_name`: 关闭这个警告
- `@warning_name`：将已启用的警告视为错误（已弃用）

`@` 开关已在 v0.10.4 中弃用。请使用 `+` 或 `-` 配置单项警告；需要让警告导致 CI 构建失败时，请使用 `moon check --deny-warn` 或相应命令的同类选项。

目前这个属性只对部分特定的警告工作。

To learn more about warning names, see [warning list](https://docs.moonbitlang.cn/toolchain/moon/package.html#warnings-list).

## Must Implement One 属性

`#must_implement_one` 属性用于 trait，要求每个实现都显式定义至少一个方法，而不是只依赖默认方法实现。

不带参数时，必须显式实现该 trait 的至少一个方法：

```
#must_implement_one
pub(open) trait RequireAnyMethod {
  f(Self) -> Unit = _
  g(Self) -> Unit = _
}

impl RequireAnyMethod with f(_) { () }

impl RequireAnyMethod with g(_) { () }

type AnyImpl

impl RequireAnyMethod for AnyImpl with f(_) { () }
```



带方法名时，必须显式实现列出的方法中的至少一个：

```
#must_implement_one(f, g)
pub(open) trait RequireSelectedMethod {
  f(Self) -> Unit = _
  g(Self) -> Unit = _
  h(Self) -> Unit = _
}

impl RequireSelectedMethod with f(_) { () }

impl RequireSelectedMethod with g(_) { () }

impl RequireSelectedMethod with h(_) { () }

type SelectedImpl

impl RequireSelectedMethod for SelectedImpl with g(_) { () }
```



同一个 trait 上可以使用多个 `#must_implement_one` 属性，以要求显式实现多个方法组中的方法。

## Inline Attribute

`#inline` 属性是函数的优化提示。它会请求编译器尽可能内联该函数：

```
#inline
fn add_one(x : Int32) -> Int32 {
  x + 1
}
```



使用 `#inline(never)` 可以请求编译器不要内联某个函数：

```
#inline(never)
fn keep_stack_frame(x : Int32) -> Int32 {
  x + 1
}
```



这些属性只是提示，不会改变函数在源码层面的行为。

## `external` 属性

`#external`属性用于标记一个抽象类型为外部类型。

- 对于 Wasm 和 Wasm GC 后端，它将被解释为 `externref`。
- 对于 JavaScript 后端，它将被解释为`any`。
- 对于原生后端，它将被解释为`void*`。

```
#external
type AttrPtr
```



## `borrow` 和 `owned` 属性

`#borrow` 和 `#owned` 属性用于 FFI 声明，用来描述带引用计数的 MoonBit 参数如何传递给外部代码。这对于 `Bytes`、`String`、`FixedArray[T]` 以及抽象类型等装箱的 MoonBit 值很重要；这些值在 C 和 Wasm 后端上的生命周期由引用计数管理。

当外部函数只在调用期间读取 `param`，且不会存储或返回它时，使用 `#borrow(param)`。借用参数仍由 MoonBit 拥有，因此外部函数不需要为它调用 `moonbit_decref` 或 `$moonbit.decref`。

当外部函数接管 `param` 的所有权时，例如将它存储起来并在之后释放，使用 `#owned(param)`。owned 参数最终必须由外部侧在不再需要时释放。

```
#borrow(filename)
extern "C" fn open(filename : Bytes, flags : Int32) -> Int32 = "open"
```



完整的调用约定规则见 [FFI 生命周期管理](https://docs.moonbitlang.cn/language/ffi.html#the-borrow-and-owned-attribute)。

## 不安全的无环属性

`#unsafe_cycle_free` 属性是用于 struct、enum 或 newtype 声明的高级优化断言。它告诉编译器，该类型的值永远不会参与引用环。编译器会在分析类型是否可能成环时信任此断言，而不会验证它。

```
#unsafe_cycle_free
pub(all) struct CycleFreeNode {
  mut next : CycleFreeNode?
}
```



危险

仅当程序能够保证无环不变量时才应使用此属性。错误的断言会使涉及该类型的引用环被视为不可能存在，从而无法回收。

## `as_free_fn` 属性

`#as_free_fn` 属性用于标记一个方法，同时它也被声明为一个自由函数。它还可以改变自由函数的可见性、自由函数的名字，并且提供单独的弃用警告。

```
#as_free_fn(dec, visibility="pub", deprecated="use `Int32::decrement` instead")
#as_free_fn(visibility="pub")
fn Int32::decrement(i : Self) -> Self {
  i - 1
}

test {
  let _ = decrement(10)
  let _ = (10).decrement()
}
```



## `callsite` 属性

`#callsite` 属性用于标记发生在调用位置的属性。

它可以是 `autofill`，用于在调用位置自动填充参数 [SourceLoc 和 ArgLoc](https://docs.moonbitlang.cn/language/fundamentals.html#id1)。

## `skip` 属性

The `#skip` attribute is used to skip a single test block. It can be written as `#skip` or with a reason, such as `#skip("blocked by external service")`. The type checking will still be performed.

## Coverage Skip Attribute

`#coverage.skip` 属性会跳过函数内的覆盖率操作。

```
#coverage.skip
fn platform_specific_helper() -> Unit {
  ()
}
```



它适用于不应影响覆盖率报告的函数，例如特定平台的回退代码，或有意排除在覆盖率统计之外的代码路径。更多细节见[跳过覆盖率](https://docs.moonbitlang.cn/toolchain/moon/coverage.html#skipping-coverage)。

## `cfg` 属性

`#cfg` 属性控制某个声明是否参与编译。条件在编译时求值，可以使用：

- `true` 或 `false`：始终包含或排除某个声明。
- `target`：选择编译后端，例如 `target="wasm"`。
- `platform`：选择 native 后端的操作系统，例如 `platform="windows"`。
- `not(...)`、`all(...)` 或 `any(...)`：分别表示条件取反、所有条件均成立或至少一个条件成立。

警告

目前，`platform` 条件也会将 target 限定为 `native`。例如，`platform="windows"` 等价于 `all(target="native", platform="windows")`。

对条件取反时需要注意这一点：`not(platform="windows")` 也会匹配所有 target 不为 `native` 的情况。若只想选择 Windows 以外的 native 构建，请使用 `all(target="native", not(platform="windows"))`。

```
#cfg(true)
fn cfg_true() -> Unit {
  ()
}

#cfg(false)
fn cfg_false() -> Unit {
  ()
}

#cfg(target="wasm")
fn cfg_wasm() -> Unit {
  ()
}

#cfg(platform="windows")
fn cfg_native_windows() -> Unit {
  ()
}

#cfg(not(platform="windows"))
fn cfg_except_native_windows() -> Unit {
  ()
}

#cfg(all(target="native", not(platform="windows")))
fn cfg_native_non_windows() -> Unit {
  ()
}

#cfg(any(target="wasm", target="native"))
fn cfg_any() -> Unit {
  ()
}
```



## 模块属性

`module` 属性用于为 JavaScript 后端声明模块依赖。

在 `cjs` 格式中，它被解释为 `require`，而在 `esm` 格式中，它被解释为 `import`。

```
#module("math-utils")
pub extern "js" fn add_from_module(x : Int32, y : Int32) -> Int32 = "add"
```



## 导出名称属性

`#export_name` 属性为使用 `pkgtype(kind: "foreign_library")` 声明的包中的公开函数指定稳定的导出符号名称。该名称用于生成的 Wasm、JavaScript 或 C 输出：

```
#export_name("add")
pub fn add_one(value : Int32) -> Int32 {
  value + 1
}
```



MoonBit 目前要求导出名在包内唯一，并且无论选择哪个后端，都必须是有效的 C 符号标识符。

警告

已知编译器问题：`#export_name` 目前会对所有后端施加 C 符号标识符限制。WebAssembly 导出名是 UTF-8 字符串，并不限于 C 标识符。

该属性不能用于泛型函数、带可选参数的函数、方法或没有函数体的声明。

对于新的导出，优先使用 `#export_name`，而不是各后端的 `exports` 链接配置。它将导出名称放在函数旁，并适用于所有支持外部库输出的后端。当导出集合或名称需要因后端而异，或者无法修改源代码添加属性时，使用 `exports`。

导出声明的作用域是生成产物的包。依赖中的属性在该依赖自身构建为产物时生效，但不会向下游包的产物添加符号。若要暴露依赖的功能，请在执行导出的包中定义并导出一个包装函数。

备注

native 后端目前不支持将 `foreign_library` 包导出为可链接的库产物，包括 `.dll` 或 `.so` 等共享库。如需导出的库，请使用 Wasm 或 JavaScript。

有关各后端的替代方式，请参阅[导出函数](https://docs.moonbitlang.cn/language/ffi.html#export-functions)。

## Proof Pure 属性

`#proof_pure` 属性使无副作用的函数可同时用于可执行代码和面向证明的逻辑。

```
#proof_pure
fn height(t : Tree) -> Int32 {
  match t {
    Empty => 0
    Node(_, _, _, h) => h
  }
}
```



目前，它支持普通的顶层函数和常规方法。`#proof_pure` 定义暂不支持验证契约、直接递归和相互递归。

有关它在规约中的作用和完整示例，请参阅[形式化验证](https://docs.moonbitlang.cn/language/verification.html#proof-specific-annotations)。

## Proof External 属性

`#proof_external(module, symbol)` 属性指示验证降级过程使用 Why3 模块中的类型表示一个抽象 MoonBit 类型。

```
///|
#proof_external("set.Fset", "fset")
pub type ProofSet[T]
```



在本例中，面向证明的逻辑中的 `ProofSet[T]` 会降级为 Why3 类型 `set.Fset.fset T`。该属性不会实现这个 MoonBit 类型、提供运行时值，也不会将该类型连接到 FFI ABI。

模块和符号映射是可信验证边界的一部分。有关对应的操作导入和证明示例，请参阅[形式化验证](https://docs.moonbitlang.cn/language/verification.html#proof-specific-annotations)。

## Proof Import 属性

`#proof_import(module)` 属性将 `.mbtp` 文件中仅用于证明的逻辑声明映射到 Why3 模块中的符号。声明的字符串函数体指定 Why3 符号；它不是可执行的 MoonBit 表达式。

```
#proof_import("set.Fset")
fn proof_set_mem(x : Int32, set : ProofSet[Int32]) -> Bool = "mem"

#proof_import("set.Fset")
fn proof_set_empty() -> ProofSet[Int32] = "empty"

#proof_import("set.Fset")
fn proof_set_add(x : Int32, set : ProofSet[Int32]) -> ProofSet[Int32] = "add"

lemma proof_set_add_contains(x : Int32) where {
  proof_ensure: proof_set_mem(
    x,
    proof_set_add(x, proof_set_empty()),
  ),
} {}
```



这里，`set.Fset` 是 Why3 模块路径，而 `"mem"`、`"empty"` 和 `"add"` 指定该模块中的符号。这些声明只影响验证降级过程，并不提供运行时实现或 FFI 绑定。最后的引理会产生证明义务；导入声明本身不会。

声明的签名和符号映射是可信验证边界的一部分。有关完整示例和使用说明，请参阅[形式化验证](https://docs.moonbitlang.cn/language/verification.html#proof-specific-annotations)。

# 外部函数接口 (FFI)

我们已经介绍的是纯粹的计算。在现实中，需要与真实世界互动。然而，对于每个后端（C、JS、Wasm、WasmGC），“世界”是不同的，并且基于运行时（[Wasmtime](https://wasmtime.dev/)、Deno、浏览器等）。

## 后端

MoonBit 目前有五个后端：

- Wasm
- Wasm GC
- JavaScript
- C
- LLVM（实验性）

对于 `native` 目标，调试构建和发布构建可能使用不同的编译器后端。在 v0.10.4 中，macOS Apple Silicon 上的调试构建默认使用新的原生后端，发布构建则使用带优化的 C 后端。新的原生后端也支持 x86-64 Linux。设置 `MOONBIT_NEW_NATIVE=0` 可强制使用 C 后端；在新后端可用但非默认的平台上，设置 `MOONBIT_NEW_NATIVE=1` 可显式启用。

Wasm

Wasm 是指包含一些 MVP 之后的提案的 WebAssembly，包括：

- 批量内存操作
- 多值
- 引用类型

为了更好的兼容性，`init` 函数会被编译成 [start function](https://webassembly.github.io/spec/core/syntax/modules.html#start-function)，而 `main` 函数会被导出为 `_start`。

备注

对于 Wasm 后端，所有与外部世界交互的函数都依赖于宿主环境。例如，Wasm 和 Wasm GC 后端的 `println` 函数依赖于导入一个函数 `spectest.print_char`，它在每次调用时打印一个 UTF-16 码元。标准库中的 `env` 包和一些 `moonbitlang/x` 包依赖于 MoonBit 运行时定义的特定宿主函数。如果您想让生成的 Wasm 可移植，请避免使用它们。

Wasm GC

JavaScript

C

LLVM

## 声明外部类型

您可以利用 `#external` 属性，像这样声明一个外部类型：

```
#external
type ExternalRef
```



Wasm 与 Wasm GC

这将被解释为一个 [`externref`](https://webassembly.github.io/spec/core/syntax/types.html#reference-types)。

JavaScript

C

## 声明外部函数

要和外部世界互动，您可以声明外部函数。

备注

MoonBit 不支持多态外部函数。

重要

当声明函数时，您需要确保函数签名与实际的外部函数相对应。**当外部函数不返回值时，请使用 `-> Unit`。在 C 中，这对应 `void`；在 Wasm 中，这对应没有返回结果的函数。**

Wasm 与 Wasm GC

声明外部函数有两种方式：导入一个函数或编写一个内联函数。

您可以通过模块名和函数名导入一个函数：

```
fn cos(d : Double) -> Double = "math" "cos"
```



或者，您可以使用 Wasm 语法编写一个内联函数：

```
extern "wasm" fn identity(d : Double) -> Double =
  #|(func (param f64) (result f64))
```



备注

编写内联函数时，请不要提供函数名称。

JavaScript

C

### 类型

下面的表格展示了一些 MoonBit 类型的底层表示：

Wasm

| MoonBit type                       | ABI         |
| ---------------------------------- | ----------- |
| `Bool`                             | `i32`       |
| `Int32`                            | `i32`       |
| `UInt32`                           | `i32`       |
| `Int64`                            | `i64`       |
| `UInt64`                           | `i64`       |
| `Float`                            | `f32`       |
| `Double`                           | `f64`       |
| constant `enum`                    | `i32`       |
| external type (`#external type T`) | `externref` |
| `FuncRef[T]`                       | `funcref`   |

Wasm GC

JavaScript

C

上表中未提及的类型不具有稳定的二进制接口，请尽量避免依赖它们的实际二进制表示。

### 回调

有时，我们想要将 MoonBit 函数作为回调传递给外部接口。在 MoonBit 中，可以定义闭包。根据 [MDN](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Guide/Closures) 的定义：

> 闭包是由捆绑起来（封闭的）的函数和函数周围状态（词法环境）的引用组合而成。换言之，闭包让函数能访问它的外部作用域。在 JavaScript 中，闭包会随着函数的创建而同时创建。

在一些场合，我们希望将传递一个回调函数，其不捕获任何局部变量。为此，MoonBit 提供了一个特殊的类型 `FuncRef[T]`，它表示类型为 `T` 的无捕获函数。类型为 `FuncRef[T]` 的值必须是类型为 `T` 的无捕获函数，否则会产生 [类型错误](https://docs.moonbitlang.cn/language/error_codes/E4151.html) 。

在其他情况下，MoonBit 函数参数会被表示为一个函数和一个包含周围状态的对象。

Wasm 与 Wasm GC

对于 Wasm 后端，回调函数会被传递为 `externref`，它表示宿主的一个函数。然而，将函数和捕获的数据转换为宿主的函数是非常重要的。

为此，Wasm 模块会在模块 `moonbit:ffi` 下导入一个函数 `make_closure`。这个函数接受一个函数和一个对象，其中函数的第一个参数应该是这个对象；并且应该返回一个宿主的函数。也就是说，宿主负责做部分调用。一个可能的实现是：

```
{ 
  "moonbit:ffi": {
    "make_closure": (funcref, closure) => funcref.bind(null, closure)
  } 
}
```



JavaScript

C

类型为 `FuncRef[_]` 的值也可以在 MoonBit 代码中直接调用。这一功能可以用于在原生后端实现动态符号加载或实现 JIT 编译。

### 自定义常量枚举的整数表示

在所有后端，常量枚举（所有构造器都没有参数的枚举）都会被编译成整数。在此基础上，MoonBit 允许用户自定义常量枚举的构造器的整数表达式。只需在构造器的声明后加上 `= <整数字面量>` 即可：

```
enum SpecialNumbers {
  Zero = 0
  One
  Two
  Three
  Ten = 10
  FourtyTwo = 42
}
```



如果一个构造器没有用户指定的整数值，默认的值是上一个构造器的值加一。（第一个构造器的默认值是 `0`）。自定义整数表示的功能在绑定一些 C 库里的 flag 是很有用。

## 导出函数

在外部库包中，`#export_name` 可以为公开函数指定其在生成的 Wasm、JavaScript 或 C 输出中的符号名称：

```
// moon.pkg
pkgtype(kind: "foreign_library")
```



```
#export_name("add")
pub fn add_one(value : Int32) -> Int32 {
  value + 1
}
```



MoonBit 目前要求导出名在包内唯一，并且无论选择哪个后端，都必须是有效的 C 符号标识符。

警告

已知编译器问题：`#export_name` 目前会对所有后端施加 C 符号标识符限制。WebAssembly 导出名是 UTF-8 字符串，并不限于 C 标识符。

该属性不能用于泛型函数、带可选参数的函数、方法或没有函数体的声明。

对于新的导出，优先使用 `#export_name`。它将导出名称放在函数旁，并适用于所有支持外部库输出的后端。

备注

native 后端目前不支持将 `foreign_library` 包导出为可链接的库产物，包括 `.dll` 或 `.so` 等共享库。

当导出集合或名称需要因后端而异，或者无法修改源代码添加属性时，使用[链接配置](https://docs.moonbitlang.cn/toolchain/moon/package.html#link-options)中各后端的 `exports` 字段：

```
options(
  "link": {
    "<backend>": {
      "exports": [ "add", "fib:test" ]
    }
  }
)
```



上述例子中导出函数 `add` 和 `fib`，其中 `fib` 会被导出为 `test`。

`#export_name` 和 `exports` 的作用域都是生成产物的包。依赖中的声明和配置在该依赖自身构建为产物时生效，但不会向下游包的产物添加符号。若要暴露依赖的功能，请在执行导出的包中定义并导出一个包装函数。

Wasm 与 Wasm GC

`exports` 字段支持如上所示的重命名。

JavaScript

C

## 生命周期管理

MoonBit 是一门具有垃圾回收的编程语言。因此在处理外部对象或将 MoonBit 对象传递给宿主时，必须牢记生命周期管理。目前，MoonBit 对 Wasm 后端和 C 后端使用引用计数。对于 Wasm GC 后端和 JavaScript 后端，复用运行时的垃圾回收机制。

### 外部对象的生命周期管理

在 MoonBit 中处理来自外部的对象和资源时，需要及时释放这些外部对象占用的内存和资源以避免泄漏。

备注

仅限 C 后端

`moonbit.h` 中提供了一个实用的函数 `moonbit_make_external_object`，它可以借助 MoonBit 的自动内存管理系统来管理外部对象的生命周期：

```
void *moonbit_make_external_object(
  void (*finalize)(void *self),
  uint32_t payload_size
);
```



`moonbit_make_external_object` 会创建一个大小为 `payload_size + sizeof(finalize)` 的新的 MoonBit 对象，这个对象的内存布局如下：

```
| MoonBit 对象头 | ... 外部数据 | 释放资源的回调 |
                 ^
                 |
                 |_
                    `moonbit_make_external_object` 返回的指针
```



因此，`moonbit_make_external_object` 返回的指针可以直接当作指向外部数据的指针使用。当 MoonBit 的自动内存管理系统发现 `moonbit_make_external_object` 返回的对象生命周期已经结束时，它会以对象自身为参数，调用创建对象时提供的 `finalize` 函数来释放这个对象占有的外部资源。

备注

`finalize` **绝对不能** 释放对象自身，因为这部分工作由 MoonBit 运行时负责。

在 MoonBit 侧，`moonbit_make_external_object` 返回的对象应当被绑定到 *抽象* 类型，即用 `type T` 语法声明的类型。这样一来，MoonBit 的内存管理系统就不会无视这个对象。

### MoonBit 对象的生命周期管理

当通过函数将 MoonBit 对象传递给宿主时，必须注意 MoonBit 对象本身的生命周期管理。如前所述，MoonBit 的 Wasm 后端和 C 后端使用编译器优化的引用计数来管理对象的生命周期。为了避免内存错误或泄漏，FFI 函数必须正确维护 MoonBit 对象的引用计数。

备注

仅限 C 后端和 Wasm 后端。

#### 引用计数的调用约定

MoonBit 的引用计数默认使用被调用者持有所有权的调用约定。也就是说，被调用的函数需要调用 `moonbit_decref` 函数来释放它的参数。如果参数被多次使用，被调用的函数需要调用 `moonbit_incref` 函数来增加引用计数。下面是不同场合下维护正确引用计数需要做的操作：

| 场合                        | 操作          |
| --------------------------- | ------------- |
| 读取字段/元素               | 什么都不做    |
| 存储进数据结构              | 调用 `incref` |
| 作为参数传递给 MoonBit 函数 | 调用 `incref` |
| 作为参数传递给其他外部函数  | 什么都不做    |
| 作为返回值被返回            | 什么都不做    |
| 作用域结束（且没有返回）    | 调用 `decref` |

下面的例子是一个正确维护引用计数的、标准的打开文件的 `open` 函数的绑定：

```
extern "C" fn open(filename : Bytes, flags : Int32) -> Int32 = "open_ffi"
```



```
int open_ffi(moonbit_bytes_t filename, int flags) {
  int fd = open(filename, flags);
  moonbit_decref(filename);
  return fd;
}
```



#### 被管理的类型

下面的类型不是分配在堆上的，不需要管理生命周期：

- 内置数字类型，例如 `Int32` 和 `Double`
- 常量枚举（所有构造器都不带参数的枚举）

下面的类型总是分配在堆上的，并且需要引用计数：

- `FixedArray[T]`, `Bytes` and `String`
- 抽象类型（`type T`）

外部类型（`#external type T`）也被分配在堆上，但它们表示外部指针，因此 MoonBit 不会对它们执行任何引用计数操作。

`struct`/有参数的 `enum` 的内存表示是不稳定的。

#### borrow 和 owned 标记

通过 FFI 传递参数时，参数的所有权可能会被保留，也可能不会。`#borrow` 和 `#owned` 标记可以用来指定这两种情况。

警告

我们正在将默认语义从 `#owned` 迁移到 `#borrow`。

`#borrow` 和 `#owned` 的语法如下：

```
#borrow(params..)
extern "C" fn c_ffi(..) -> .. = ..
```



其中，`params` 是 `c_ffi` 的参数列表的一个子集。

被 `#borrow` 标记的参数会使用基于借用的调用约定，也就是说，被调用的函数不需要对这些参数调用 `decref`。如果 FFI 函数只会在运行期间读取它的参数（不会返回它的参数或把它们存进数据结构），那么使用 `#borrow` 标记可以直接绑定 FFI 函数。上面的 `open` 的例子可以使用 `#borrow` 标记来简化：

```
#borrow(filename)
extern "C" fn open(filename : Bytes, flags : Int32) -> Int32 = "open"
```



这里不再需要 C 胶水函数：我们直接绑定到了原版 `open`。`#borrow` 标记保证了这个简化的版本依然能正确维护引用计数。

即使由于某些其他原因依然需要写 C 胶水函数，`#borrow` 标记也可以用于简化 C 胶水内部的生命周期管理。下面是不同场合下，正确维护 **借用参数** 的引用计数需要做的操作：

| 场合                                       | 操作          |
| ------------------------------------------ | ------------- |
| 读取字段/元素                              | 什么都不做    |
| 存储进数据结构                             | 调用 `incref` |
| 作为参数传递给 MoonBit 函数                | 调用 `incref` |
| 传递给其他 C 函数 / `#borrow` MoonBit 函数 | 什么都不做    |
| 作为返回值被返回                           | 调用 `incref` |
| 作用域结束（且没有返回）                   | 什么都不做    |

`#owned` 语义与之相反，表示参数会被 FFI 函数存储，并且需要在稍后手动调用 `decref`。一个使用场景是注册回调函数，其中闭包会被 **持有所有权**。

# 异步编程支持

MoonBit 采用了一种类似 [Kotlin](https://kotlinlang.org/docs/coroutines-overview.html) 的、基于协程的方式来支持异步编程。MoonBit 的异步编程支持由两部分组成：MoonBit 编译器中对 `async` 函数的支持，以及 MoonBit 的官方异步运行时 `moonbitlang/async`。目前，`moonbitlang/async` 对 native 后端的支持最好，对 JavaScript 后端的支持有限，并提供实验性的 Wasm1 支持。`moonbitlang/async` 的 API 尚未稳定，未来可能发生变化。

## 在 MoonBit 中使用异步编程

要在 MoonBit 中使用 `moonbitlang/async` 异步编程，首先需要运行 `moon add moonbitlang/async@0.20.2` 将 `moonbitlang/async` 添加为项目依赖。也可以在 `moon.mod` 中设置 `preferred_target = "native"`。这之后，只需要在 `moon.pkg` 的 `import` 中添加 `moonbitlang/async` 的各个包，就能使用 `moonbitlang/async` 中的各种异步编程 API 了。如果你想看一个以工作流为主线的示例，可以参考[原生 CLI 快速开始](https://docs.moonbitlang.cn/tutorial/cli-quickstart.html)。

可以在 [mooncakes.io](https://mooncakes.io/docs/moonbitlang/async) 查询`moonbitlang/async` 中的包列表以及它们各自的详细文档，还可以在 `moonbitlang/async` 的 GitHub 仓库中找到一些简单的 [例子](https://github.com/moonbitlang/async/tree/main/examples)。这篇文章会介绍 `moonbitlang/async` 的基本概念和其中最重要的一些 API。

## 异步函数

异步函数用 `async` 关键字定义。他们隐式地 [抛出错误](https://docs.moonbitlang.cn/language/error-handling.html#throwing-errors) ，而如果不抛出错误则需要显式地声明 `noraise`。

```
async fn my_async_function() -> String {
  let (response, body) = @http.get("https://www.moonbitlang.cn")
  guard response.code is (200..<300) else {
    fail("server responded with \{response.code} \{response.reason}")
  }
  body.text()
}
```



由于 MoonBit 是一门静态类型语言，编译器会跟踪异步函数的调用，因此你可以像调用普通函数一样调用异步函数。MoonBit IDE 会用不同的样式来高亮显示异步函数的调用。例如，如果在 MoonBit IDE 中打开上面的代码片段，就会看到 `@http.get` 函数被渲染成了斜体 + 下划线的效果。

异步函数只能在异步函数中被调用。调用一个 `async` 函数会使调用者阻塞并等待被调用的函数返回，类似其他语言中的 `await`。

MoonBit 对异步编程有原生的支持。可以用 `async fn main` 来声明异步的程序入口，或者用 `async test` 来编写异步测试。默认情况下，多个异步测试可以并行地同时运行。注意使用 `async fn main` 或 `async test` 需要在 `moon.pkg` 中添加 `moonbitlang/async` 作为依赖。

异步函数默认可取消。添加 `nocancel` 表示函数不会引入取消。`nocancel` 异步函数可以调用同步函数和其他 `nocancel` 异步函数，但不能调用可取消的异步函数。这个效应与普通错误相互独立：`noraise` 排除普通错误，而 `noraise + nocancel` 同时排除普通错误和取消。

```
async fn record_completion() -> Unit noraise + nocancel {
  println("completed")
}
```



## 结构化并发与任务组

如果一段异步程序除了直接调用其他异步函数没有做别的事情，那么它的控制流会是线性的，和普通的同步程序没有区别。异步程序和同步程序最本质的不同，在于异步程序能同时创建多个任务，并让它们同时运行。由于多个异步任务可以同时运行，异步程序的控制流会复杂许多因此，创建多个任务的能力也带来了新的挑战：如何健壮地管理任务。

`moonbitlang/async` 采用了 *结构化并发* 这一编程范式来解决任务管理的问题，并提升异步程序的健壮性。在 `moonbitlang/async` 中，新任务只能在一个 *任务组* 中被创建。而任务组必须通过 `@async.with_task_group` 函数创建：

```
async fn[Result] with_task_group(
  f : async (@async.TaskGroup[Result]) -> Result,
) -> Result
```



`with_task_group` 函数会创建一个新的任务组，在其中创建一个新的任务，并在这个任务中以任务组自己为参数运行 `f`。`f` 可以通过 `spawn_bg` 等方法来使用任务组创建更多任务：

```
/// 在任务组中创建一个新的任务并在后台运行它
fn[Result] @async.TaskGroup::spawn_bg(
  group : TaskGroup[Result],
  f : async () -> Unit,
  ...
) -> Unit
```



结构化并发范式的“魔法”就在 `with_task_group` 需要遵守的一条规则之中：

> 只有当任务组中的所有任务都结束了，`with_task_group` 才会返回

`with_task_group` 会保证上述规则在所有情况下都成立。正常情况下，`with_task_group` 会等待所有任务正常结束。如果 `with_task_group` 因为某些原因需要提前结束，例如某个任务失败了（默认情况下，如果任务组中的某个任务失败了，`with_task_group` 也会立刻失败，从而确保错误不会被不小心忽略），它会取消所有还在运行的任务，并等待它们的清理工作完成。结果上看，`with_task_group` 的规则保证了 *孤儿任务*（由于忘记被取消，明明已经没用了但仍在运行的任务）在 `moonbitlang/async` 中不可能出现。

下面是一个使用 `with_task_group` 创建多个任务，并让它们同时运行的例子：

```
async test "with_task_group" {
  let log = []
  @async.with_task_group(group => {
    group.spawn_bg(() => {
      for _ in 0..<3 {
        log.push("task #1 tick")
        @async.sleep(200) // sleep for 200ms
      }
    })
    group.spawn_bg(() => {
      @async.sleep(100)
      for _ in 0..<3 {
        log.push("task #2 tick")
        @async.sleep(200)
      }
    })
  })
  json_inspect(log, content=[
    "task #1 tick", "task #2 tick", "task #1 tick", "task #2 tick", "task #1 tick",
    "task #2 tick",
  ])
}
```



`with_task_group` 是一个非常强大的构造。它能模拟许多其他异步控制流原语。例如，下面是一个使用 `with_task_group` 实现的、给一个异步函数添加超时限制的辅助函数：

```
async fn with_timeout(timeout : Int32, f : async () -> Unit) -> Unit {
  @async.with_task_group(group => {
    group.spawn_bg(no_wait=true, () => {
      @async.sleep(timeout)
      raise Failure::Failure("timeout!")
    })
    f()
  })
}
```



这段代码非常简短。但是 `with_task_group` 的语义保证了这个简单的小函数在所有边界情况上都能有正确的行为：

- 如果 `f` 在超时之前顺利返回，由于创建负责计时的任务时设置了 `no_wait=true`，`with_task_group` 不会等待计时任务完成，会立即准备结束。为了维护 `with_task_group` 的性质，计时任务会立即被取消并结束。因此，`with_timeout(.., f)` 会在 `f` 返回时立刻返回，不会有不必要的延迟。
- 如果 `f` 失败了，它抛出的错误会传播到整个 `with_task_group` 上。此时，计时任务同样会被自动取消。
- 如果 `f` 超时了，计时任务会抛出一个错误，终止整个任务组。此时，`f` 会被自动取消，因此不会有资源泄漏。

## 通过取消机制实现模块化的异步程序

在前面的章节中，我们多次提到了“取消”这一概念。在异步编程中，能够取消一个正在运行的任务是非常重要的。在 `moonbitlang/async` 中，包括 `with_task_group` 在内的所有异步操作默认都是可取消的。所以，当用户使用这些基础操作组合出大规模的异步程序时，无论最终得到的程序有多复杂，它依然自动是可取消的。

当一段异步代码被取消时，取消信号会在代码先前阻塞的位置被抛出。普通的 `catch` 处理器不会捕获该信号。它会自动在程序中传播，同时由 `defer` 或 `errdefer` 注册的清理仍然会运行。

取消任意异步代码的能力使 MoonBit 中的异步程序变得高度模块化。`moonbitlang/async` 包提供了许多使用的异步辅助函数，例如给一段异步代码加上超时、自动重试等。这些辅助函数都依赖于取消机制。例如，下面是一段尝试在时限内进行一次 HTTP 请求，并允许至多三次重试的程序：

```
async fn make_request() -> String {
  @async.retry(Immediate, max_retry=3, () => {
    @async.with_timeout(1000, () => {
      let (response, body) = @http.get("https://www.moonbitlang.com")
      guard response.code is (200..<300) else {
        fail("the HTTP request is not successful")
      }
      body.text()
    })
  })
}
```



## 和外部世界交互

除了各种异步编程原语，`moonbitlang/async` 还提供了一个 [性能优秀](https://www.moonbitlang.com/blog/moonbit-async#performance-comparison) 的 IO 事件循环，以及一系列丰富的异步 IO 操作，包括 `http`/`https`、文件 IO、网络 IO 和创建外部进程。可以在 [mooncakes.io](https://mooncakes.io/docs/moonbitlang/async) 找到完整的 API 列表和它们的详细文档，也可以在 `moonbitlang/async` 的 [GitHub 仓库](https://github.com/moonbitlang/async/tree/main/examples) 找到一些简单示例。下面是一个小例子：

```
async fn download_file(url : String, file_name : String) -> Unit {
  // 流式地处理内容以节省内存
  let (_response, body) = @http.get_stream(url)
  defer body.close()
  let out_file = @fs.create(file_name, permission=0o644)
  defer out_file.close()
  out_file.write_reader(body)
}
```



## JavaScript 支持

虽然 `moonbitlang/async` 对 native 后端支持最好，它也对 JavaScript 后端有基本的支持：

- 所有 IO 无关的 API，例如任务组、超时等，都可以在 JavaScript 后端使用
- JavaScript 后端无法使用 IO 相关的 API，因为不是所有 JavaScript 环境（例如浏览器）都支持这些 IO 操作
- `moonbitlang/async/js_async` 包可以用来和 JavaScript promise 互动。它提供了等待一个 JavaScript promise 和把一个 MoonBit `async` 函数包装成一个 JavaScript promise 的功能。利用这个功能，用户可以自行绑定目标 JavaScript 环境中支持的异步操作。

关于和 JavaScript 互动的更多信息，可以参考 `moonbitlang/async/js_async` 的 [mooncakes.io 页面](https://mooncakes.io/docs/moonbitlang/async/js_async)。

## 实验性的 Wasm1 支持

0.20.2 版本新增了实验性的 Wasm1 支持，其 API 签名和行为与 native 后端一致。目前，使用此支持构建的程序需要最新的 `moonrun`，尚不能兼容其他 WebAssembly 运行时。Wasm1 后端暂不支持 `@websocket`、`@fs.Watcher` 或 `@fs.realpath`。

# 形式化验证

MoonBit 通过 `moon prove` 提供实验性的形式化验证支持。你可以编写可执行的 MoonBit 代码，为这些代码陈述逻辑性质，并借助 SMT 求解器证明生成的证明任务。

从整体上看，工作流程如下：

1. 在 `.mbt` 文件中编写可执行代码。
2. 在 `.mbtp` 文件中编写谓词、逻辑辅助函数和引理。
3. 在包中启用证明模式。
4. 运行 `moon prove`。

## 概览示例：二分查找

下面这个包简要展示了 MoonBit 中各项验证机制如何配合工作。它展示了：

- 在包级别启用证明
- `.mbtp` 中的逻辑侧谓词
- `.mbt` 中的程序侧函数
- 前置条件与后置条件
- 循环不变量与 `proof_yield`
- 局部的 `proof_assert` 步骤
- 用 `proof_reasoning` 对循环进行面向证明的说明

首先，为该包启用证明：

```
proof_enabled = true
```



然后在 `.mbtp` 中定义逻辑侧规范：

```
predicate in_bounds(xs : FixedArray[Int32], i : Int32) {
  (0 <= i) && (i < xs.length())
}

predicate sorted(xs : FixedArray[Int32]) {
  ∀ i : Int32, ∀ j : Int32,
    in_bounds(xs, i) && in_bounds(xs, j) && (i <= j) →
      xs[i] <= xs[j]
}

predicate binary_search_ok(xs : FixedArray[Int32], key : Int32, result : Option[Int32]) {
  match result {
    None => ∀ i : Int32, in_bounds(xs, i) → xs[i] != key
    Some(result) => in_bounds(xs, result) && xs[result] == key
  }
}
```



最后，在 `.mbt` 中实现可执行函数：

```
pub fn binary_search(
  xs : FixedArray[Int32],
  key : Int32,
) -> Int32? where {
  proof_require: sorted(xs),
  proof_ensure: result => binary_search_ok(xs, key, result),
} {
  for i = 0, j = xs.length(); i < j; {
    let h = i + (j - i) / 2
    if xs[h] < key {
      proof_assert ∀ idx : Int32,
        (0 <= idx) && (idx < h + 1) → xs[idx] < key
      continue h + 1, j
    } else if key < xs[h] {
      proof_assert ∀ idx : Int32,
        (h <= idx) && (idx < xs.length()) → key < xs[idx]
      continue i, h
    } else {
      proof_assert xs[h] == key
      break Some(h)
    }
  } nobreak {
    None
  } where {
    proof_invariant: 0 <= i,
    proof_invariant: i <= j,
    proof_invariant: j <= xs.length(),
    proof_invariant: ∀ idx : Int32, (0 <= idx) && (idx < i) → xs[idx] < key,
    proof_invariant: ∀ idx : Int32, (j <= idx) && (idx < xs.length()) → key < xs[idx],
    proof_yield: res => binary_search_ok(xs, key, res),
    proof_reasoning: (
      #| The loop maintains a candidate window `[i, j)`.
      #| Every index before `i` is known to hold a value `< key`, and every
      #| index from `j` onward is known to hold a value `> key`.
      #|
      #| At midpoint `h` there are three cases:
      #|   - `xs[h] < key`: move the left boundary to `h + 1`
      #|   - `key < xs[h]`: move the right boundary to `h`
      #|   - otherwise, the element at `h` is equal to `key`
      #|
      #| If the loop exits normally, the exclusion invariants cover the whole
      #| array, so no index can contain `key`.
    ),
  }
}
```



这个示例已经展示了经过验证的 MoonBit 代码的主要结构：

- `sorted` 与 `binary_search_ok` 是逻辑侧谓词
- `binary_search` 是可执行的程序侧代码
- `where { ... }` 块将逻辑侧契约附加到函数上
- `proof_assert` 记录有助于证明器求解的局部条件
- 循环不变量描述逐步收缩的搜索窗口
- `proof_reasoning` 用结构化文字记录证明思路

本页后续部分会更详细地解释这些组成部分，并介绍 `#proof_pure`、`#proof_external`、`#proof_import`、`proof_decrease`、`proof_axiomatized`、基于模型的验证，以及可信边界等附加特性。

## 环境准备

### 环境配置

`moon prove` 依赖外部的 Why3 验证工具链。MoonBit 会将启用了证明的包转换为 Why3，随后由 Why3 将证明任务分派给一个或多个外部求解器。

### Why3

在 MoonBit 中运行形式化验证必须安装 Why3。

- 推荐通过 `opam` 安装 Why3。
- 推荐固定使用的版本为 `1.7.2`。

使用 `opam` 更容易让 Why3 与当前 MoonBit 证明流水线所期望的版本保持一致。

### 外部求解器

还必须至少安装一个外部求解器。

MoonBit 当前支持：

- `z3`
- `cvc5`
- `alt-ergo`

安装多个求解器有助于提高证明覆盖率，但一个可用的环境只需要其中任意一个即可。

### 在包中启用证明

证明支持是按包在 `moon.pkg` 中启用的，如上面的概览示例所示。

启用后，该包既可以包含普通的 MoonBit 源文件，也可以包含面向证明的 `.mbtp` 文件。如果一个模块中的多个包都包含证明，那么每个这样的包都必须分别启用它。

## 包含验证的代码的结构

### 源码布局

面向验证的包通常会分成两层：

- `.mbt`：可执行代码、契约、循环不变量和局部证明步骤
- `.mbtp`：谓词、抽象模型、不变量和引理

这种拆分方式在保持运行时代码可读性的同时，也让证明结构更加明确。在 [二分查找概览示例](https://docs.moonbitlang.cn/language/verification.html#overview-example-binary-search) 中，谓词位于 `.mbtp` 中，而可执行的搜索函数位于 `.mbt` 中。

### 程序侧与逻辑侧

MoonBit 的验证系统明确区分程序侧与逻辑侧。

- 程序侧是可执行的 MoonBit 代码。
- 逻辑侧用于编写规范与证明，它可能根本不对应任何运行时代码。

`.mbt` 文件中的定义属于程序侧，`.mbtp` 文件中的定义属于逻辑侧。

这种区分很重要，因为程序侧定义与逻辑侧定义是分离的：

- 程序侧定义是可执行的，可以被普通 MoonBit 代码调用
- 逻辑侧定义用于规范与证明
- `.mbtp` 中的逻辑侧定义不是普通的运行时函数
- 程序侧代码在执行过程中不会调用逻辑侧定义
- 逻辑侧规范通常也不会任意调用程序侧定义

正因为有这种分离，带证明的包通常会同时包含：

- 供执行时使用的程序侧辅助函数
- 供契约使用的逻辑侧谓词或模型函数

当某个定义需要同时在两侧可见时，就可以使用 `#proof_pure`。

在 `.mbt` 文件中，契约和证明注解是逻辑侧推理嵌入程序代码的位置。具体来说：

- `proof_require` 和 `proof_ensure` 是附加在程序函数上的逻辑侧规范
- `proof_assert` 声明一个必须在该位置被证明的逻辑事实
- 诸如 `proof_invariant`、`proof_yield` 和 `proof_reasoning` 之类的循环注解，都是关于可执行循环的逻辑侧陈述

## 编写规范与证明

### `.mbt` 中的契约

MoonBit 使用 `where { ... }` 子句来编写函数契约。在二分查找概览示例中，函数契约直接写在程序侧定义上：

- `proof_require` 声明前置条件。
- `proof_ensure` 声明后置条件。
- `result` 指代函数结果。

在可执行代码内部，可以用 `proof_assert` 记录中间事实，帮助证明器把实现与规范关联起来。

这通常就是把程序侧实现事实连接到逻辑侧谓词和后置条件的地方。

### 证明专用注解

除了 `proof_require`、`proof_ensure` 和 `proof_assert` 之外，MoonBit 还提供了一些证明专用注解，用于控制证明流水线如何处理这些定义。

### `#proof_pure`

`#proof_pure` 从验证器的角度将一个函数标记为纯函数。这适用于那些计算逻辑量的辅助函数：它们会出现在谓词和后置条件中，同时又需要在程序侧可见。

```
#proof_pure
fn height(t : Tree) -> Int32 {
  match t {
    Empty => 0
    Node(_, _, _, h) => h
  }
}
```



同一个辅助函数随后就可以在规范中使用：

```
predicate cached_height_ok(t : Tree, result : Int32) {
  result == height(t)
}
```



`#proof_pure` 的动机在于，有些计算天然同时属于两侧。例如树的 `height` 这样的辅助函数，在可执行代码中很有用，而规范也可能需要引用同一个量。

如果没有 `#proof_pure`，通常就意味着：

- 写一个供执行使用的程序侧定义
- 再写一个供规范使用的逻辑侧定义
- 在使用之前还要证明这两个定义是等价的

`#proof_pure` 允许一个无副作用的 MoonBit 定义被程序代码和面向证明的逻辑共同使用，从而避免这种重复。

在更大的验证包中，`#proof_pure` 常用于诸如高度这类结构度量、排序函数、汇总函数，以及其他应当像数学函数一样工作的面向证明的计算。

目前，`#proof_pure` 辅助函数更适合视为纯规范辅助函数，而不是带完整契约的已验证函数。当前仅支持普通顶层函数和普通方法；`#proof_pure` 定义尚不支持验证契约、直接递归或相互递归。

### 外部理论：`#proof_external` 与 `#proof_import`

面向证明的库有时会暴露一个 MoonBit 类型，而其逻辑模型由现有的 Why3 理论提供。以下两个属性共同构成这座桥梁：

- `#proof_external(module, symbol)` 指示证明降级过程使用 Why3 模块中的类型表示一个抽象 MoonBit 类型。
- `#proof_import(module)` 为 Why3 模块中的操作声明一个仅用于证明的 stub。

例如，在验证过程中，可以使用 Why3 的 `set.Fset.fset` 类型表示一个不透明载体：

```
///|
#proof_external("set.Fset", "fset")
pub type ProofSet[T]
```



随后，证明侧可以为 Why3 操作声明 stub，并使用导入的有限集合理论证明性质。stub 的参数顺序必须与 Why3 符号一致：

```
#proof_import("set.Fset")
fn proof_set_mem(x : Int32, set : ProofSet[Int32]) -> Bool = "mem"

#proof_import("set.Fset")
fn proof_set_empty() -> ProofSet[Int32] = "empty"

#proof_import("set.Fset")
fn proof_set_add(x : Int32, set : ProofSet[Int32]) -> ProofSet[Int32] = "add"

lemma proof_set_add_contains(x : Int32) where {
  proof_ensure: proof_set_mem(
    x,
    proof_set_add(x, proof_set_empty()),
  ),
} {}
```



这里，`set.Fset` 是 Why3 模块路径，字符串函数体 `"mem"` 指定该模块中的符号。字符串函数体是 `.mbtp` 文件接受的特殊 proof-stub 语法；它不是可执行的 MoonBit 表达式，也与 MoonBit FFI 无关。最后的引理是一项真正的证明义务，由导入的 Why3 理论消解；这些声明都不能由运行时 MoonBit 代码调用。

这两个属性都只影响验证降级过程。`#proof_external` 不会实现 MoonBit 类型，也不会将其连接到运行时 ABI；`#proof_import` 不会提供可执行函数体。所声明的签名及其到 Why3 符号的映射属于可信集成边界。

### `proof_decrease`

`proof_decrease` 为递归定义提供终止度量。

```
pub fn countdown(n : Int32) -> Int32 where {
  proof_decrease: n,
  proof_require: 0 <= n,
  proof_ensure: result => 0 <= result,
} {
  if n <= 0 {
    0
  } else {
    countdown(n - 1)
  }
}
```



当证明器无法仅从函数体中直接看出结构递归或数值度量时，这个注解尤其重要。

### `proof_axiomatized`

`proof_axiomatized` 将一个带契约的函数或引理标记为“被假定成立”，而不是“被证明成立”。

当某个定义需要供后续证明使用，但其实现或证明被有意留在当前验证边界之外时，这会很有用。

在实践中，应当谨慎使用 `proof_axiomatized`：

- 用于函数时，表示验证器会直接假定所声明的契约成立
- 用于引理时，表示验证器会直接假定所声明的结论成立

例如：

```
pub fn assumed_nonnegative(x : Int32) -> Int32 where {
  proof_axiomatized: true,
  proof_require: 0 <= x,
  proof_ensure: result => 0 <= result,
} {
  x
}
```



当证明仍在开发过程中时，这类声明可以作为临时桥梁；或者当可信边界是有意且明确设定时，也可以使用它。关键在于，`moon prove` 会把该契约当作假设来使用，而不是从函数体出发对其进行证明。

由于这些假设不会被 `moon prove` 消解，它们就会成为已验证包可信边界的一部分。

### `.mbtp` 中的谓词与引理

逻辑性质定义在 `.mbtp` 文件中。在 [二分查找概览示例](https://docs.moonbitlang.cn/language/verification.html#overview-example-binary-search) 中，逻辑侧定义了：

- 把 `in_bounds` 作为基本索引谓词
- 把 `sorted` 作为输入数组的前置条件
- 把 `binary_search_ok` 作为把结果与数组及键值关联起来的后置条件

例如，`.mbtp` 中的谓词可以定义契约所使用的逻辑词汇：

```
predicate in_bounds(xs : FixedArray[Int32], i : Int32) {
  (0 <= i) && (i < xs.length())
}

predicate sorted(xs : FixedArray[Int32]) {
  ∀ i : Int32, ∀ j : Int32,
    in_bounds(xs, i) && in_bounds(xs, j) && (i <= j) →
      xs[i] <= xs[j]
}

predicate binary_search_ok(xs : FixedArray[Int32], key : Int32, result : Option[Int32]) {
  match result {
    None => ∀ i : Int32, in_bounds(xs, i) → xs[i] != key
    Some(result) => in_bounds(xs, result) && xs[result] == key
  }
}
```



对于更大的验证包，`.mbtp` 还会包含：

- 如 `model(x)` 这样的抽象模型函数
- 如 `bridge_inv(x)` 或 `sparse_array_inv(x)` 这样的表示不变量
- 如 `deposit_post(...)` 这样的具名后置条件
- 可复用的引理

引理是仅用于证明的声明，用来表达可复用的事实。当证明器可以直接消解时，较小的引理可以拥有空函数体；而更大的引理则可以使用递归的证明结构：

```
lemma height_nonneg_lemma(t : Tree) where {
  proof_decrease: t,
  proof_require: avl_inv(t),
  proof_ensure: 0 <= height(t),
} {
  match t {
    Empty => ()
    Node(l, _x, r, _h) => {
      height_nonneg_lemma(l)
      height_nonneg_lemma(r)
    }
  }
}
```



在这个例子中，`avl_inv` 是 AVL 树的表示不变量，而这个引理通过对 `t` 进行结构递归来证明 `height(t)` 非负。

引理体会随着求解器所需的证明引导程度而有所不同：

- 有些引理的函数体为空，因为验证器可以直接完成证明
- 有些引理会使用一连串 `proof_assert` 步骤来显式给出中间事实
- 递归引理还可以调用其他引理，包括在更小输入上递归调用自身

### 循环不变量

循环通过循环的 `where { ... }` 块中的证明专用子句来验证。在 [二分查找概览示例](https://docs.moonbitlang.cn/language/verification.html#overview-example-binary-search) 中，循环不变量说明了：

- 当前搜索窗口始终是一个合法的区间 `[i, j)`
- `i` 之前的每个索引都包含 `< key` 的值
- 从 `j` 开始的每个索引都包含 `> key` 的值

最常见的循环证明注解有：

- `proof_invariant`：在每次迭代边界都必须成立的事实
- `proof_yield`：对由 `break` 产出的值必须成立的事实
- `proof_reasoning`：解释循环为何正确的面向证明的说明

在实践中，好的循环不变量通常描述当前搜索窗口、前缀或已处理区域，而不是一次性描述整个算法。

### 基于模型的验证

对于数据结构和有状态系统，最有用的模式通常是：

1. 定义一个抽象模型，
2. 定义一个表示不变量，
3. 针对该抽象模型来为每个操作编写规范。

AVL 树就是这种风格的一个代表性例子：

```
fn Tree::model(self : Tree) -> Fset[Int32] {
  match self {
    Empty => Fset::empty()
    Node(l, x, r, _) => l.model().union(r.model()).add(x)
  }
}

predicate avl_inv(t : Tree) {
  match t {
    Empty => true
    Node(l, x, r, h) =>
      avl_inv(l) &&
      avl_inv(r) &&
      (∀ y : Int32, l.model().mem(y) → y < x) &&
      (∀ y : Int32, r.model().mem(y) → x < y) &&
      h == 1 + max2(height(l), height(r)) &&
      -1 <= height(l) - height(r) &&
      height(l) - height(r) <= 1
  }
}
```



这里：

- `model()` 把具体的树映射为它的抽象有限集合视图
- 内联的量词条件描述了该抽象模型上的顺序约束
- `avl_inv` 将递归的良构性、搜索树顺序以及缓存高度的正确性绑定在一起

与在每个契约中直接写庞大的内联布尔公式相比，这种风格的可扩展性要好得多。每个操作都可以基于抽象模型和不变量来编写规范，而实现部分则通过证明局部事实，最终推出相应的具名后置条件。

### 推荐风格

- 把可执行逻辑放在 `.mbt` 中，把证明逻辑放在 `.mbtp` 中。
- 将程序侧和逻辑侧视为两个不同的层次，它们之间只通过一个狭窄的桥梁连接。
- 优先使用具名谓词，而不是大型内联公式。
- 使用小而稳定的不变量和后置条件，例如 `*_inv` 与 `*_post`。
- 当证明器需要帮助时，在重要的构造步骤、分支和循环更新之后加入 `proof_assert`。
- 从简单的算法证明开始，然后再过渡到针对数据结构和协议的基于模型的验证。
- 谨慎设计递归辅助函数：`#proof_pure` 和 `proof_decrease` 往往决定了一个证明是否仍然易于维护。

## 运行验证

### `moon prove` 会检查什么

运行 `moon prove` 会要求验证器证明如下几类义务：

- 函数前置条件足以保证函数体可以安全执行
- 后置条件在每一条返回路径上都成立
- `proof_assert` 语句是有效的
- 循环不变量初始成立，并且在循环过程中得以保持
- 当循环形式支持时，循环的终止度量会递减
- 证明所需的边界检查和类似的安全性质

### 运行验证器

在模块根目录下运行：

```
moon prove
```



这会尝试证明当前模块中所有启用了证明的包。

如果只想证明一个包，可以传入它的路径：

```
moon prove path/to/package
```



在这种定向模式下，MoonBit 只会尝试证明被选中的包；它的依赖会被当作假设，而不会作为同一条命令的一部分重新证明。

MoonBit 会把启用了证明的包转换为 Why3，并调用已配置的证明器处理生成的验证条件。

`moon check` 和 `moon prove` 在这里承担不同的职责。`moon check` 负责把包作为 MoonBit 代码进行校验，而 `moon prove` 则尝试消解它的证明义务。

## 可信模型与限制

### 受信假设

和任何验证系统一样，MoonBit 的证明体系也有一个可信边界：某些事实由前端和后端直接假定，而不是在用户代码内部加以证明。

任何用户编写且标记为 `proof_axiomatized` 的项目，也属于这个可信边界。

当前主要的可信假设包括：

- 验证所推理的是数学整数，而不是机器整数
- 任何标记为 `proof_axiomatized` 的项目都会被当作假设，而不是被证明
- 使用 `#proof_external` 或 `#proof_import` 的声明正确描述了预期的 Why3 类型和操作

对整数来说，这意味着证明义务是在一个无界整数模型下进行检查的。因此：

- 算术证明目前不会建模运行时溢出
- 一个程序在证明模型中可能是正确的，但在实际执行时仍然需要显式的范围约束
- 机器整数验证已经在计划中，但目前还不是默认模型

### 当前状态

MoonBit 中的形式化验证仍处于实验阶段。表面语法、证明器集成和证明易用性都还在快速演进，因此最好把它视为一种高级特性，主要面向那些确实能从强而可机检的保证中受益的包。

### 推荐的验证风格

MoonBit 当前的验证器最适合函数式的证明风格，以及基于模型的规范。

诸如局部可变状态和原地 `FixedArray` 更新这样的命令式特性虽然受支持，但它们在验证中的使用限制更多：

- 可变状态应当保持为局部使用
- `FixedArray` 的逃逸式使用目前还不受支持
- 当两种写法都可行时，优先选择函数式风格的程序

## 进一步阅读

如果想查看更多已验证程序和可复用的面向证明的库，请参考 [`moonbit-community/verified`](https://github.com/moonbit-community/verified) 仓库。

# 词法约定

本页面规定 MoonBit 的词法形式。运行时表示、API 和字面量重载见[基础](https://docs.moonbitlang.cn/language/fundamentals.html#built-in-data-structures)。

MoonBit 源文本必须是格式正确的 UTF-8。格式错误的输入会报告词法错误。在每个位置，词法分析器都会取最长的有效词法单元。空白会被丢弃，而换行参与自动分号插入。

在产生式中，`{ symbol }` 表示重复零次或多次，`{ symbol }+` 表示重复一次或多次，`[ symbol ]` 表示出现零次或一次，`x...y` 表示包含两端的范围。圆括号用于组合形式。`except` 子句从其左侧的完整形式中排除所列形式。

## 通用词法类

```
unicode-scalar-value ::= U+0000...U+D7FF | U+E000...U+10FFFF

newline-character ::= LF | CR | U+2028 | U+2029

newline ::= newline-character | CR LF

whitespace ::= U+0009 | U+000B | U+000C | U+0020 | U+00A0 | U+1680
             | U+2000...U+200A | U+202F | U+205F | U+3000 | U+FEFF

line-character ::= unicode-scalar-value except newline-character
```

## 字符串字面量

```
string-literal ::= " { string-character } "

string-character ::= regular-string-character
                   | simple-escape-sequence
                   | unicode-escape-sequence
                   | interpolation

regular-string-character ::= unicode-scalar-value
                             except ", \, and newline-character

simple-escape-sequence ::= \ (\ | " | ' | n | t | b | r | f | /)

unicode-escape-sequence ::= \u (0...9 | A...F | a...f) (0...9 | A...F | a...f)
                            (0...9 | A...F | a...f) (0...9 | A...F | a...f)
                          | \u{ { 0...9 | A...F | a...f }+ }
```

简单转义序列的含义如下：

| 序列 | 字符                 |
| ---- | -------------------- |
| `\\` | 反斜杠（U+005C）     |
| `\"` | 双引号（U+0022）     |
| `\'` | 单引号（U+0027）     |
| `\/` | 正斜杠（U+002F）     |
| `\n` | 换行符（U+000A）     |
| `\r` | 回车符（U+000D）     |
| `\t` | 水平制表符（U+0009） |
| `\b` | 退格符（U+0008）     |
| `\f` | 换页符（U+000C）     |

Unicode 转义必须表示 Unicode 标量值。若在右引号之前遇到换行，则报告未终止的字符串字面量。

### 插值

```
interpolation ::= \{ { whitespace } expression { whitespace } }
```

表达式不能为空，且必须在与之匹配的 `}` 处结束。嵌套字面量中的大括号不影响匹配。嵌套插值会被递归识别。不允许出现换行、`//` 注释、属性和多行字符串字面量。

## 多行字符串字面量

```
multiline-string-literal ::= multiline-string-line
                           { newline multiline-string-line }

multiline-string-line ::= raw-multiline-string-line
                        | interpolated-multiline-string-line

raw-multiline-string-line ::= #| { multiline-regular-character }

interpolated-multiline-string-line ::= $| { multiline-regular-character | interpolation }

multiline-regular-character ::= unicode-scalar-value
                                except newline-character
```

结果中省略各行前缀，并使用 U+000A 连接各行。最后一个带前缀的空行会添加末尾换行符。`#|` 行是原样文本。在 `$|` 行中，只有 `\{` 会开始插值。插值表达式内不允许多行字符串。

## 字节序列字面量

```
bytes-literal ::= b" { bytes-character } "

bytes-character ::= regular-string-character
                  | simple-escape-sequence
                  | byte-escape-sequence
                  | interpolation

byte-escape-sequence ::= \x (0...9 | A...F | a...f) (0...9 | A...F | a...f)
                       | \o (0...3) (0...7) (0...7)
```

若在右引号之前遇到换行，则报告未终止的字面量。非 ASCII 源字符写入其 UTF-8 编码。`\xHH` 和 `\oDDD` 各写入一个取值为 0 到 255 的字节。插值遵循字符串字面量规则。字节序列字面量没有多行形式。

## 正则字面量

```
regex-literal ::= re" { regex-character } "

regex-character ::= regular-string-character
                  | \ (unicode-scalar-value except { and newline-character)
                  | interpolation
```

反斜杠会原样保留给正则解析器，而 `\{` 会开始插值。带插值的正则字面量仅在 lex-pattern 上下文中接受。若在右引号之前遇到换行，则报告未终止的字面量。参见[正则字面量表达式](https://docs.moonbitlang.cn/language/fundamentals.html#regex-literal-expression)。

## 字符字面量

```
character-literal ::= ' regular-character '
                    | ' character-escape-sequence '

regular-character ::= unicode-scalar-value
                      except ', \, and newline-character

character-escape-sequence ::= simple-escape-sequence
                            | unicode-escape-sequence
```

字符字面量恰好包含一个 Unicode 标量值或转义序列。

## 字节字面量

```
byte-literal ::= b' regular-byte-character '
               | b' byte-character-escape-sequence '

regular-byte-character ::= (U+0000...U+007F)
                           except ', \, and newline-character

byte-character-escape-sequence ::= simple-escape-sequence
                                 | byte-escape-sequence
```

未转义的字节必须是 ASCII。字节字面量中不允许 Unicode 转义。

## 注释

```
doc-comment ::= /// { line-character }

line-comment ::= // { line-character }
```

当两者都能匹配时，`doc-comment` 优先于 `line-comment`。MoonBit 不支持块注释。

## 标识符

```
non-ascii ::= U+00A1...U+00AC
              | U+00AE...U+02AF
              | U+1100...U+11FF
              | U+1E00...U+1EFF
              | U+2070...U+209F
              | U+2150...U+218F
              | U+2E80...U+2EFF
              | U+2FF0...U+2FFF
              | U+3001...U+30FF
              | U+31C0...U+9FFF
              | U+AC00...U+D7FF
              | U+F900...U+FAFF
              | U+FE00...U+FE0F
              | U+FE30...U+FE4F
              | U+1F000...U+1FBFF
              | U+20000...U+2A6DF
              | U+2A700...U+2EBEF
              | U+2F800...U+2FA1F
              | U+30000...U+323AF
              | U+E0100...U+E01EF

uident ::= (A...Z) { A...Z | a...z | 0...9 | _ | non-ascii }

lident ::= _ { A...Z | a...z | 0...9 | _ | non-ascii }+
         | (a...z | non-ascii) { A...Z | a...z | 0...9 | _ | non-ascii }

underscore ::= _
```

以上字符范围按原样使用，不进行 Unicode 规范化。`uident` 以 ASCII 大写字母开头。其他标识符拼写以 ASCII 小写字母、`_` 或 `non-ascii` 中的字符开头。单独的 `_` 是专用词法单元。关键字也使用各自的专用词法单元。以 ASCII 十进制数字开头时会开始一个数字字面量。

### 关键字

```
keyword ::= as | else | extern | fn | if | let
          | const | match | using | mut | type
          | struct | enum | extenum | trait
          | derive | while | break | continue | import | return
          | throw | raise | try | catch | pub | priv
          | proof_assert | proof_let | readonly | true | false
          | test | loop | for | in | impl | with
          | guard | async | is | suberror | and | letrec
          | enumview | noraise | nocancel | defer | lexscan | lexmatch
          | where | declare | nobreak | extend | try! | guard!
```

关键字优先于标识符。

以下拼写为保留字。尚未成为关键字的保留字会被词法分析为标识符或标签，并报告保留关键字警告。

```
reserved-word ::= module | move | ref | static | super | unsafe
                | use | await | dyn | abstract | do | final
                | macro | override | typeof | virtual | yield
                | local | method | alias | assert | package
                | recur | isnot | define
                | downcast | inherit | member | namespace | upcast
                | void | lazy | include | mixin | protected
                | sealed | constructor | atomic | volatile
                | anyframe | anytype | asm | comptime | errdefer
                | export | opaque | orelse | resume | threadlocal
                | unreachable | dynclass | dynobj | dynrec | var
                | finally | noasync | assume
```

### 标签

```
label ::= _ { A...Z | a...z | 0...9 | _ | non-ascii }+ ~
        | ((a...z | non-ascii) { A...Z | a...z | 0...9 | _ | non-ascii } ~) except keyword~
```

`~` 必须紧跟名称。以 ASCII 大写字母开头的标识符和关键字不能构成标签。

## 包名

```
package-part ::= (A...Z | a...z | _) { A...Z | a...z | 0...9 | _ | - }

package-name ::= @ package-part { / package-part }
```

包名仅限 ASCII。连字符不能位于包名部分的开头。前导 `@`、斜杠和各个部分必须彼此相邻。

## 属性

```
attribute-name ::= (A...Z | a...z | _) { A...Z | a...z | 0...9 | _ }

attribute ::= # attribute-name [ . attribute-name ] { line-character }
```

可选的点号限定名之后，到下一个换行为止的所有内容都是原始载荷。`interpolation` 中不允许使用属性。载荷文法见[属性](https://docs.moonbitlang.cn/language/attributes.html)。

## 数字字面量

```
integer-nums ::= (0...9) { 0...9 | _ }
               | 0 (x | X) (0...9 | A...F | a...f) { 0...9 | A...F | a...f | _ }
               | 0 (o | O) (0...7) { 0...7 | _ }
               | 0 (b | B) (0 | 1) { 0 | 1 | _ }

integer-literal ::= integer-nums [ UL | U | L | N ]

double-dec ::= (0...9) { 0...9 | _ } . { 0...9 | _ }
               [ (e | E) [ + | - ] (0...9) { 0...9 | _ } ]

double-hex ::= 0 (x | X) (0...9 | A...F | a...f)
               { 0...9 | A...F | a...f | _ } .
               { 0...9 | A...F | a...f | _ }
               [ (p | P) [ + | - ] (0...9) { 0...9 | _ } ]

double-literal ::= double-dec | double-hex

float-dec ::= double-dec F

float-hex ::= 0 (x | X) (0...9 | A...F | a...f)
              { 0...9 | A...F | a...f | _ } .
              { 0...9 | A...F | a...f | _ }
              (p | P) [ + | - ] (0...9) { 0...9 | _ } F

float-literal ::= float-dec | float-hex
```

数的第一个数字之后，下划线可以重复出现，也可以出现在末尾。大写后缀分别指定 `UInt32`（`U`）、`Int64`（`L`）、`UInt64`（`UL`）、`BigInt`（`N`）或 `Float`（`F`）。不带后缀的浮点字面量为 `Double`。

浮点字面量始终包含小数点。十六进制 `Float` 必须在 `F` 前包含由 `p` 或 `P` 引导的指数部分，因此 `0x1.F` 是 `Double`。正负号是独立的词法单元。紧接 `..` 时，整数词法单元先结束，因此 `1..=2` 以 `1` 和 `..=` 开始。

`1.` 和 `1.F` 也分别是合法的 `Double` 和 `Float` 字面量。

## 点号前缀词法单元

```
tuple-accessor ::= . { 0...9 }+

dot-identifier ::= . (A...Z | a...z | _ | non-ascii) { A...Z | a...z | 0...9 | _ | non-ascii }
```

这些形式中不能包含空白。元组访问器中不能有下划线。点号标识符遵循标识符的大小写规则，但不查询关键字表，因此 `.if` 合法。单独的 `.` 会报告词法错误。

## 运算符与分隔符

```
delimiter ::= ( | ) | , | :: | : | ;
            | [ | ] | { | } | [| | |]

operator ::= => | ->
           | && | & | ^
           | * | / | %
           | << | >>
           | = | > | <| | <? | <+ | <
           | == | != | =~ | <= | >=
           | | | || | + | - | ? | !
           | += | -= | *= | /= | %= | |>
           | .. | ..= | ..< | ..<= | >.. | >=.. | ...
```

列出的词法单元中，最长者优先。

## 自动分号插入

换行后，如果前一个词法单元可以结束语句，且后一个词法单元可以开始语句，词法分析器可能会插入 `;`。文件末尾也可作为有效的后继。词法分析器不会在 `}` 前插入分号，也不会在多行字符串的相邻行之间插入分号。

## `.mbti` 扩展

`.mbti` 的词法文法在 `.mbt` 的基础上增加以下关键字：

```
mbti-keyword ::= keyword | package
```

在 `.mbti` 中，`package` 的匹配优先级高于标识符，且不能构成标签。在 `.mbt` 中，它遵循上文所述的保留字规则，并可构成 `package~`。

# 错误代码索引

警告

该错误代码索引目前正在编写中。

许多条目目前只有非常简短的错误代码描述。我们非常欢迎您通过向 [moonbitlang/moonbit-docs](https://github.com/moonbitlang/moonbit-docs) 提交 Pull Request 的方式来扩充条目内容。

此页面列出了所有 MoonBit 编译器会报告的错误。

- [E0001](https://docs.moonbitlang.cn/language/error_codes/E0001.html)
- [E0002](https://docs.moonbitlang.cn/language/error_codes/E0002.html)
- [E0003](https://docs.moonbitlang.cn/language/error_codes/E0003.html)
- [E0004](https://docs.moonbitlang.cn/language/error_codes/E0004.html)
- [E0005](https://docs.moonbitlang.cn/language/error_codes/E0005.html)
- [E0006](https://docs.moonbitlang.cn/language/error_codes/E0006.html)
- [E0007](https://docs.moonbitlang.cn/language/error_codes/E0007.html)
- [E0008](https://docs.moonbitlang.cn/language/error_codes/E0008.html)
- [E0009](https://docs.moonbitlang.cn/language/error_codes/E0009.html)
- [E0010](https://docs.moonbitlang.cn/language/error_codes/E0010.html)
- [E0011](https://docs.moonbitlang.cn/language/error_codes/E0011.html)
- [E0012](https://docs.moonbitlang.cn/language/error_codes/E0012.html)
- [E0013](https://docs.moonbitlang.cn/language/error_codes/E0013.html)
- [E0014](https://docs.moonbitlang.cn/language/error_codes/E0014.html)
- [E0015](https://docs.moonbitlang.cn/language/error_codes/E0015.html)
- [E0016](https://docs.moonbitlang.cn/language/error_codes/E0016.html)
- [E0017](https://docs.moonbitlang.cn/language/error_codes/E0017.html)
- [E0018](https://docs.moonbitlang.cn/language/error_codes/E0018.html)
- [E0020](https://docs.moonbitlang.cn/language/error_codes/E0020.html)
- [E0021](https://docs.moonbitlang.cn/language/error_codes/E0021.html)
- [E0022](https://docs.moonbitlang.cn/language/error_codes/E0022.html)
- [E0023](https://docs.moonbitlang.cn/language/error_codes/E0023.html)
- [E0024](https://docs.moonbitlang.cn/language/error_codes/E0024.html)
- [E0025](https://docs.moonbitlang.cn/language/error_codes/E0025.html)
- [E0026](https://docs.moonbitlang.cn/language/error_codes/E0026.html)
- [E0027](https://docs.moonbitlang.cn/language/error_codes/E0027.html)
- [E0028](https://docs.moonbitlang.cn/language/error_codes/E0028.html)
- [E0029](https://docs.moonbitlang.cn/language/error_codes/E0029.html)
- [E0030](https://docs.moonbitlang.cn/language/error_codes/E0030.html)
- [E0031](https://docs.moonbitlang.cn/language/error_codes/E0031.html)
- [E0032](https://docs.moonbitlang.cn/language/error_codes/E0032.html)
- [E0033](https://docs.moonbitlang.cn/language/error_codes/E0033.html)
- [E0034](https://docs.moonbitlang.cn/language/error_codes/E0034.html)
- [E0035](https://docs.moonbitlang.cn/language/error_codes/E0035.html)
- [E0036](https://docs.moonbitlang.cn/language/error_codes/E0036.html)
- [E0037](https://docs.moonbitlang.cn/language/error_codes/E0037.html)
- [E0038](https://docs.moonbitlang.cn/language/error_codes/E0038.html)
- [E0039](https://docs.moonbitlang.cn/language/error_codes/E0039.html)
- [E0040](https://docs.moonbitlang.cn/language/error_codes/E0040.html)
- [E0041](https://docs.moonbitlang.cn/language/error_codes/E0041.html)
- [E0042](https://docs.moonbitlang.cn/language/error_codes/E0042.html)
- [E0043](https://docs.moonbitlang.cn/language/error_codes/E0043.html)
- [E0044](https://docs.moonbitlang.cn/language/error_codes/E0044.html)
- [E0045](https://docs.moonbitlang.cn/language/error_codes/E0045.html)
- [E0046](https://docs.moonbitlang.cn/language/error_codes/E0046.html)
- [E0047](https://docs.moonbitlang.cn/language/error_codes/E0047.html)
- [E0049](https://docs.moonbitlang.cn/language/error_codes/E0049.html)
- [E0050](https://docs.moonbitlang.cn/language/error_codes/E0050.html)
- [E0051](https://docs.moonbitlang.cn/language/error_codes/E0051.html)
- [E0052](https://docs.moonbitlang.cn/language/error_codes/E0052.html)
- [E0053](https://docs.moonbitlang.cn/language/error_codes/E0053.html)
- [E0054](https://docs.moonbitlang.cn/language/error_codes/E0054.html)
- [E0055](https://docs.moonbitlang.cn/language/error_codes/E0055.html)
- [E0056](https://docs.moonbitlang.cn/language/error_codes/E0056.html)
- [E0057](https://docs.moonbitlang.cn/language/error_codes/E0057.html)
- [E0059](https://docs.moonbitlang.cn/language/error_codes/E0059.html)
- [E0060](https://docs.moonbitlang.cn/language/error_codes/E0060.html)
- [E0061](https://docs.moonbitlang.cn/language/error_codes/E0061.html)
- [E0062](https://docs.moonbitlang.cn/language/error_codes/E0062.html)
- [E0063](https://docs.moonbitlang.cn/language/error_codes/E0063.html)
- [E0064](https://docs.moonbitlang.cn/language/error_codes/E0064.html)
- [E0065](https://docs.moonbitlang.cn/language/error_codes/E0065.html)
- [E0066](https://docs.moonbitlang.cn/language/error_codes/E0066.html)
- [E0067](https://docs.moonbitlang.cn/language/error_codes/E0067.html)
- [E0068](https://docs.moonbitlang.cn/language/error_codes/E0068.html)
- [E0069](https://docs.moonbitlang.cn/language/error_codes/E0069.html)
- [E0070](https://docs.moonbitlang.cn/language/error_codes/E0070.html)
- [E0071](https://docs.moonbitlang.cn/language/error_codes/E0071.html)
- [E0072](https://docs.moonbitlang.cn/language/error_codes/E0072.html)
- [E0073](https://docs.moonbitlang.cn/language/error_codes/E0073.html)
- [E0074](https://docs.moonbitlang.cn/language/error_codes/E0074.html)
- [E0075](https://docs.moonbitlang.cn/language/error_codes/E0075.html)
- [E0076](https://docs.moonbitlang.cn/language/error_codes/E0076.html)
- [E0077](https://docs.moonbitlang.cn/language/error_codes/E0077.html)
- [E0078](https://docs.moonbitlang.cn/language/error_codes/E0078.html)
- [E0079](https://docs.moonbitlang.cn/language/error_codes/E0079.html)
- [E0080](https://docs.moonbitlang.cn/language/error_codes/E0080.html)
- [E0081](https://docs.moonbitlang.cn/language/error_codes/E0081.html)
- [E0082](https://docs.moonbitlang.cn/language/error_codes/E0082.html)
- [E0083](https://docs.moonbitlang.cn/language/error_codes/E0083.html)
- [E0084](https://docs.moonbitlang.cn/language/error_codes/E0084.html)
- [E0085](https://docs.moonbitlang.cn/language/error_codes/E0085.html)
- [E0086](https://docs.moonbitlang.cn/language/error_codes/E0086.html)
- [E0087](https://docs.moonbitlang.cn/language/error_codes/E0087.html)
- [E0088](https://docs.moonbitlang.cn/language/error_codes/E0088.html)
- [E0089](https://docs.moonbitlang.cn/language/error_codes/E0089.html)
- [E0090](https://docs.moonbitlang.cn/language/error_codes/E0090.html)
- [E0091](https://docs.moonbitlang.cn/language/error_codes/E0091.html)
- [E0092](https://docs.moonbitlang.cn/language/error_codes/E0092.html)
- [E0093](https://docs.moonbitlang.cn/language/error_codes/E0093.html)
- [E1000](https://docs.moonbitlang.cn/language/error_codes/E1000.html)
- [E1001](https://docs.moonbitlang.cn/language/error_codes/E1001.html)
- [E3001](https://docs.moonbitlang.cn/language/error_codes/E3001.html)
- [E3002](https://docs.moonbitlang.cn/language/error_codes/E3002.html)
- [E3003](https://docs.moonbitlang.cn/language/error_codes/E3003.html)
- [E3004](https://docs.moonbitlang.cn/language/error_codes/E3004.html)
- [E3005](https://docs.moonbitlang.cn/language/error_codes/E3005.html)
- [E3006](https://docs.moonbitlang.cn/language/error_codes/E3006.html)
- [E3007](https://docs.moonbitlang.cn/language/error_codes/E3007.html)
- [E3008](https://docs.moonbitlang.cn/language/error_codes/E3008.html)
- [E3009](https://docs.moonbitlang.cn/language/error_codes/E3009.html)
- [E3010](https://docs.moonbitlang.cn/language/error_codes/E3010.html)
- [E3011](https://docs.moonbitlang.cn/language/error_codes/E3011.html)
- [E3012](https://docs.moonbitlang.cn/language/error_codes/E3012.html)
- [E3014](https://docs.moonbitlang.cn/language/error_codes/E3014.html)
- [E3016](https://docs.moonbitlang.cn/language/error_codes/E3016.html)
- [E3017](https://docs.moonbitlang.cn/language/error_codes/E3017.html)
- [E3018](https://docs.moonbitlang.cn/language/error_codes/E3018.html)
- [E3019](https://docs.moonbitlang.cn/language/error_codes/E3019.html)
- [E3020](https://docs.moonbitlang.cn/language/error_codes/E3020.html)
- [E3021](https://docs.moonbitlang.cn/language/error_codes/E3021.html)
- [E3022](https://docs.moonbitlang.cn/language/error_codes/E3022.html)
- [E3023](https://docs.moonbitlang.cn/language/error_codes/E3023.html)
- [E3024](https://docs.moonbitlang.cn/language/error_codes/E3024.html)
- [E3026](https://docs.moonbitlang.cn/language/error_codes/E3026.html)
- [E3027](https://docs.moonbitlang.cn/language/error_codes/E3027.html)
- [E3100](https://docs.moonbitlang.cn/language/error_codes/E3100.html)
- [E3700](https://docs.moonbitlang.cn/language/error_codes/E3700.html)
- [E3800](https://docs.moonbitlang.cn/language/error_codes/E3800.html)
- [E3801](https://docs.moonbitlang.cn/language/error_codes/E3801.html)
- [E4000](https://docs.moonbitlang.cn/language/error_codes/E4000.html)
- [E4001](https://docs.moonbitlang.cn/language/error_codes/E4001.html)
- [E4002](https://docs.moonbitlang.cn/language/error_codes/E4002.html)
- [E4003](https://docs.moonbitlang.cn/language/error_codes/E4003.html)
- [E4005](https://docs.moonbitlang.cn/language/error_codes/E4005.html)
- [E4006](https://docs.moonbitlang.cn/language/error_codes/E4006.html)
- [E4008](https://docs.moonbitlang.cn/language/error_codes/E4008.html)
- [E4010](https://docs.moonbitlang.cn/language/error_codes/E4010.html)
- [E4011](https://docs.moonbitlang.cn/language/error_codes/E4011.html)
- [E4012](https://docs.moonbitlang.cn/language/error_codes/E4012.html)
- [E4013](https://docs.moonbitlang.cn/language/error_codes/E4013.html)
- [E4014](https://docs.moonbitlang.cn/language/error_codes/E4014.html)
- [E4015](https://docs.moonbitlang.cn/language/error_codes/E4015.html)
- [E4017](https://docs.moonbitlang.cn/language/error_codes/E4017.html)
- [E4018](https://docs.moonbitlang.cn/language/error_codes/E4018.html)
- [E4019](https://docs.moonbitlang.cn/language/error_codes/E4019.html)
- [E4020](https://docs.moonbitlang.cn/language/error_codes/E4020.html)
- [E4021](https://docs.moonbitlang.cn/language/error_codes/E4021.html)
- [E4022](https://docs.moonbitlang.cn/language/error_codes/E4022.html)
- [E4023](https://docs.moonbitlang.cn/language/error_codes/E4023.html)
- [E4024](https://docs.moonbitlang.cn/language/error_codes/E4024.html)
- [E4027](https://docs.moonbitlang.cn/language/error_codes/E4027.html)
- [E4028](https://docs.moonbitlang.cn/language/error_codes/E4028.html)
- [E4029](https://docs.moonbitlang.cn/language/error_codes/E4029.html)
- [E4031](https://docs.moonbitlang.cn/language/error_codes/E4031.html)
- [E4032](https://docs.moonbitlang.cn/language/error_codes/E4032.html)
- [E4033](https://docs.moonbitlang.cn/language/error_codes/E4033.html)
- [E4034](https://docs.moonbitlang.cn/language/error_codes/E4034.html)
- [E4036](https://docs.moonbitlang.cn/language/error_codes/E4036.html)
- [E4037](https://docs.moonbitlang.cn/language/error_codes/E4037.html)
- [E4038](https://docs.moonbitlang.cn/language/error_codes/E4038.html)
- [E4039](https://docs.moonbitlang.cn/language/error_codes/E4039.html)
- [E4040](https://docs.moonbitlang.cn/language/error_codes/E4040.html)
- [E4041](https://docs.moonbitlang.cn/language/error_codes/E4041.html)
- [E4042](https://docs.moonbitlang.cn/language/error_codes/E4042.html)
- [E4043](https://docs.moonbitlang.cn/language/error_codes/E4043.html)
- [E4044](https://docs.moonbitlang.cn/language/error_codes/E4044.html)
- [E4046](https://docs.moonbitlang.cn/language/error_codes/E4046.html)
- [E4047](https://docs.moonbitlang.cn/language/error_codes/E4047.html)
- [E4048](https://docs.moonbitlang.cn/language/error_codes/E4048.html)
- [E4049](https://docs.moonbitlang.cn/language/error_codes/E4049.html)
- [E4050](https://docs.moonbitlang.cn/language/error_codes/E4050.html)
- [E4051](https://docs.moonbitlang.cn/language/error_codes/E4051.html)
- [E4052](https://docs.moonbitlang.cn/language/error_codes/E4052.html)
- [E4053](https://docs.moonbitlang.cn/language/error_codes/E4053.html)
- [E4054](https://docs.moonbitlang.cn/language/error_codes/E4054.html)
- [E4055](https://docs.moonbitlang.cn/language/error_codes/E4055.html)
- [E4056](https://docs.moonbitlang.cn/language/error_codes/E4056.html)
- [E4057](https://docs.moonbitlang.cn/language/error_codes/E4057.html)
- [E4059](https://docs.moonbitlang.cn/language/error_codes/E4059.html)
- [E4061](https://docs.moonbitlang.cn/language/error_codes/E4061.html)
- [E4063](https://docs.moonbitlang.cn/language/error_codes/E4063.html)
- [E4064](https://docs.moonbitlang.cn/language/error_codes/E4064.html)
- [E4065](https://docs.moonbitlang.cn/language/error_codes/E4065.html)
- [E4066](https://docs.moonbitlang.cn/language/error_codes/E4066.html)
- [E4067](https://docs.moonbitlang.cn/language/error_codes/E4067.html)
- [E4068](https://docs.moonbitlang.cn/language/error_codes/E4068.html)
- [E4069](https://docs.moonbitlang.cn/language/error_codes/E4069.html)
- [E4070](https://docs.moonbitlang.cn/language/error_codes/E4070.html)
- [E4071](https://docs.moonbitlang.cn/language/error_codes/E4071.html)
- [E4073](https://docs.moonbitlang.cn/language/error_codes/E4073.html)
- [E4074](https://docs.moonbitlang.cn/language/error_codes/E4074.html)
- [E4077](https://docs.moonbitlang.cn/language/error_codes/E4077.html)
- [E4078](https://docs.moonbitlang.cn/language/error_codes/E4078.html)
- [E4080](https://docs.moonbitlang.cn/language/error_codes/E4080.html)
- [E4081](https://docs.moonbitlang.cn/language/error_codes/E4081.html)
- [E4082](https://docs.moonbitlang.cn/language/error_codes/E4082.html)
- [E4083](https://docs.moonbitlang.cn/language/error_codes/E4083.html)
- [E4084](https://docs.moonbitlang.cn/language/error_codes/E4084.html)
- [E4085](https://docs.moonbitlang.cn/language/error_codes/E4085.html)
- [E4086](https://docs.moonbitlang.cn/language/error_codes/E4086.html)
- [E4087](https://docs.moonbitlang.cn/language/error_codes/E4087.html)
- [E4089](https://docs.moonbitlang.cn/language/error_codes/E4089.html)
- [E4091](https://docs.moonbitlang.cn/language/error_codes/E4091.html)
- [E4092](https://docs.moonbitlang.cn/language/error_codes/E4092.html)
- [E4093](https://docs.moonbitlang.cn/language/error_codes/E4093.html)
- [E4094](https://docs.moonbitlang.cn/language/error_codes/E4094.html)
- [E4095](https://docs.moonbitlang.cn/language/error_codes/E4095.html)
- [E4096](https://docs.moonbitlang.cn/language/error_codes/E4096.html)
- [E4099](https://docs.moonbitlang.cn/language/error_codes/E4099.html)
- [E4100](https://docs.moonbitlang.cn/language/error_codes/E4100.html)
- [E4101](https://docs.moonbitlang.cn/language/error_codes/E4101.html)
- [E4102](https://docs.moonbitlang.cn/language/error_codes/E4102.html)
- [E4104](https://docs.moonbitlang.cn/language/error_codes/E4104.html)
- [E4106](https://docs.moonbitlang.cn/language/error_codes/E4106.html)
- [E4107](https://docs.moonbitlang.cn/language/error_codes/E4107.html)
- [E4108](https://docs.moonbitlang.cn/language/error_codes/E4108.html)
- [E4109](https://docs.moonbitlang.cn/language/error_codes/E4109.html)
- [E4110](https://docs.moonbitlang.cn/language/error_codes/E4110.html)
- [E4111](https://docs.moonbitlang.cn/language/error_codes/E4111.html)
- [E4112](https://docs.moonbitlang.cn/language/error_codes/E4112.html)
- [E4113](https://docs.moonbitlang.cn/language/error_codes/E4113.html)
- [E4114](https://docs.moonbitlang.cn/language/error_codes/E4114.html)
- [E4115](https://docs.moonbitlang.cn/language/error_codes/E4115.html)
- [E4116](https://docs.moonbitlang.cn/language/error_codes/E4116.html)
- [E4117](https://docs.moonbitlang.cn/language/error_codes/E4117.html)
- [E4118](https://docs.moonbitlang.cn/language/error_codes/E4118.html)
- [E4119](https://docs.moonbitlang.cn/language/error_codes/E4119.html)
- [E4120](https://docs.moonbitlang.cn/language/error_codes/E4120.html)
- [E4122](https://docs.moonbitlang.cn/language/error_codes/E4122.html)
- [E4124](https://docs.moonbitlang.cn/language/error_codes/E4124.html)
- [E4127](https://docs.moonbitlang.cn/language/error_codes/E4127.html)
- [E4128](https://docs.moonbitlang.cn/language/error_codes/E4128.html)
- [E4130](https://docs.moonbitlang.cn/language/error_codes/E4130.html)
- [E4131](https://docs.moonbitlang.cn/language/error_codes/E4131.html)
- [E4132](https://docs.moonbitlang.cn/language/error_codes/E4132.html)
- [E4133](https://docs.moonbitlang.cn/language/error_codes/E4133.html)
- [E4134](https://docs.moonbitlang.cn/language/error_codes/E4134.html)
- [E4135](https://docs.moonbitlang.cn/language/error_codes/E4135.html)
- [E4137](https://docs.moonbitlang.cn/language/error_codes/E4137.html)
- [E4138](https://docs.moonbitlang.cn/language/error_codes/E4138.html)
- [E4139](https://docs.moonbitlang.cn/language/error_codes/E4139.html)
- [E4140](https://docs.moonbitlang.cn/language/error_codes/E4140.html)
- [E4141](https://docs.moonbitlang.cn/language/error_codes/E4141.html)
- [E4142](https://docs.moonbitlang.cn/language/error_codes/E4142.html)
- [E4143](https://docs.moonbitlang.cn/language/error_codes/E4143.html)
- [E4144](https://docs.moonbitlang.cn/language/error_codes/E4144.html)
- [E4145](https://docs.moonbitlang.cn/language/error_codes/E4145.html)
- [E4146](https://docs.moonbitlang.cn/language/error_codes/E4146.html)
- [E4147](https://docs.moonbitlang.cn/language/error_codes/E4147.html)
- [E4148](https://docs.moonbitlang.cn/language/error_codes/E4148.html)
- [E4149](https://docs.moonbitlang.cn/language/error_codes/E4149.html)
- [E4151](https://docs.moonbitlang.cn/language/error_codes/E4151.html)
- [E4153](https://docs.moonbitlang.cn/language/error_codes/E4153.html)
- [E4154](https://docs.moonbitlang.cn/language/error_codes/E4154.html)
- [E4155](https://docs.moonbitlang.cn/language/error_codes/E4155.html)
- [E4156](https://docs.moonbitlang.cn/language/error_codes/E4156.html)
- [E4157](https://docs.moonbitlang.cn/language/error_codes/E4157.html)
- [E4158](https://docs.moonbitlang.cn/language/error_codes/E4158.html)
- [E4159](https://docs.moonbitlang.cn/language/error_codes/E4159.html)
- [E4160](https://docs.moonbitlang.cn/language/error_codes/E4160.html)
- [E4161](https://docs.moonbitlang.cn/language/error_codes/E4161.html)
- [E4162](https://docs.moonbitlang.cn/language/error_codes/E4162.html)
- [E4163](https://docs.moonbitlang.cn/language/error_codes/E4163.html)
- [E4164](https://docs.moonbitlang.cn/language/error_codes/E4164.html)
- [E4165](https://docs.moonbitlang.cn/language/error_codes/E4165.html)
- [E4167](https://docs.moonbitlang.cn/language/error_codes/E4167.html)
- [E4168](https://docs.moonbitlang.cn/language/error_codes/E4168.html)
- [E4171](https://docs.moonbitlang.cn/language/error_codes/E4171.html)
- [E4172](https://docs.moonbitlang.cn/language/error_codes/E4172.html)
- [E4173](https://docs.moonbitlang.cn/language/error_codes/E4173.html)
- [E4174](https://docs.moonbitlang.cn/language/error_codes/E4174.html)
- [E4175](https://docs.moonbitlang.cn/language/error_codes/E4175.html)
- [E4177](https://docs.moonbitlang.cn/language/error_codes/E4177.html)
- [E4180](https://docs.moonbitlang.cn/language/error_codes/E4180.html)
- [E4181](https://docs.moonbitlang.cn/language/error_codes/E4181.html)
- [E4187](https://docs.moonbitlang.cn/language/error_codes/E4187.html)
- [E4188](https://docs.moonbitlang.cn/language/error_codes/E4188.html)
- [E4189](https://docs.moonbitlang.cn/language/error_codes/E4189.html)
- [E4190](https://docs.moonbitlang.cn/language/error_codes/E4190.html)
- [E4191](https://docs.moonbitlang.cn/language/error_codes/E4191.html)
- [E4192](https://docs.moonbitlang.cn/language/error_codes/E4192.html)
- [E4193](https://docs.moonbitlang.cn/language/error_codes/E4193.html)
- [E4194](https://docs.moonbitlang.cn/language/error_codes/E4194.html)
- [E4195](https://docs.moonbitlang.cn/language/error_codes/E4195.html)
- [E4196](https://docs.moonbitlang.cn/language/error_codes/E4196.html)
- [E4197](https://docs.moonbitlang.cn/language/error_codes/E4197.html)
- [E4199](https://docs.moonbitlang.cn/language/error_codes/E4199.html)
- [E4200](https://docs.moonbitlang.cn/language/error_codes/E4200.html)
- [E4202](https://docs.moonbitlang.cn/language/error_codes/E4202.html)
- [E4203](https://docs.moonbitlang.cn/language/error_codes/E4203.html)
- [E4204](https://docs.moonbitlang.cn/language/error_codes/E4204.html)
- [E4205](https://docs.moonbitlang.cn/language/error_codes/E4205.html)
- [E4206](https://docs.moonbitlang.cn/language/error_codes/E4206.html)
- [E4207](https://docs.moonbitlang.cn/language/error_codes/E4207.html)
- [E4208](https://docs.moonbitlang.cn/language/error_codes/E4208.html)
- [E4209](https://docs.moonbitlang.cn/language/error_codes/E4209.html)
- [E4210](https://docs.moonbitlang.cn/language/error_codes/E4210.html)
- [E4211](https://docs.moonbitlang.cn/language/error_codes/E4211.html)
- [E4212](https://docs.moonbitlang.cn/language/error_codes/E4212.html)
- [E4213](https://docs.moonbitlang.cn/language/error_codes/E4213.html)
- [E4214](https://docs.moonbitlang.cn/language/error_codes/E4214.html)
- [E4215](https://docs.moonbitlang.cn/language/error_codes/E4215.html)
- [E4216](https://docs.moonbitlang.cn/language/error_codes/E4216.html)
- [E4218](https://docs.moonbitlang.cn/language/error_codes/E4218.html)
- [E4219](https://docs.moonbitlang.cn/language/error_codes/E4219.html)
- [E4220](https://docs.moonbitlang.cn/language/error_codes/E4220.html)
- [E4221](https://docs.moonbitlang.cn/language/error_codes/E4221.html)
- [E4222](https://docs.moonbitlang.cn/language/error_codes/E4222.html)
- [E4224](https://docs.moonbitlang.cn/language/error_codes/E4224.html)
- [E4225](https://docs.moonbitlang.cn/language/error_codes/E4225.html)
- [E4226](https://docs.moonbitlang.cn/language/error_codes/E4226.html)
- [E4227](https://docs.moonbitlang.cn/language/error_codes/E4227.html)
- [E4228](https://docs.moonbitlang.cn/language/error_codes/E4228.html)
- [E4229](https://docs.moonbitlang.cn/language/error_codes/E4229.html)
- [E4230](https://docs.moonbitlang.cn/language/error_codes/E4230.html)

[上一页词法约定](https://docs.moonbitlang.cn/language/lexical-conventions.html)[下一页E0001](https://docs.moonbitlang.cn/language/error_codes/E0001.html)

# 工具链

- [MoonBit 的构建系统](https://docs.moonbitlang.cn/toolchain/moon/index.html)：`moon`构建系统的完整手册。
- [MoonBit 的 Agent IDE](https://docs.moonbitlang.cn/toolchain/moonide/index.html)：`moon ide`（代理 IDE）的完整手册。
- [MoonBit 的 VSCode 插件](https://docs.moonbitlang.cn/toolchain/vscode/index.html)：关于 VSCode 插件的提示。

其他工具链

- [WebAssembly 工具链](https://docs.moonbitlang.cn/toolchain/wasm/index.html)：如何在 MoonBit 中使用 Wasm。
- …

[下载本章节的 Markdown 版本](https://docs.moonbitlang.cn/_downloads/7e67a7065021137fc80a2750bac9ee32/summary.md)

目录：

- Moon 构建系统
  - [MoonBit 构建系统教程](https://docs.moonbitlang.cn/toolchain/moon/tutorial.html)
  - [运行 `.mbtx` 脚本](https://docs.moonbitlang.cn/toolchain/moon/script-mode.html)
  - [使用与发布包](https://docs.moonbitlang.cn/toolchain/moon/package-manage-tour.html)
  - [工作区支持](https://docs.moonbitlang.cn/toolchain/moon/workspace.html)
  - [`moon`的命令行帮助](https://docs.moonbitlang.cn/toolchain/moon/commands.html)
  - [模块配置](https://docs.moonbitlang.cn/toolchain/moon/module.html)
  - [包配置](https://docs.moonbitlang.cn/toolchain/moon/package.html)
  - [测量代码覆盖率](https://docs.moonbitlang.cn/toolchain/moon/coverage.html)
- MoonBit Agent IDE
  - [概览](https://docs.moonbitlang.cn/toolchain/moonide/index.html#overview)
  - [符号语法](https://docs.moonbitlang.cn/toolchain/moonide/index.html#symbol-syntax)
  - [`moon ide peek-def` - 查看符号定义](https://docs.moonbitlang.cn/toolchain/moonide/index.html#moon-ide-peek-def-view-symbol-definitions)
  - [`moon ide find-references` - 追踪所有用法](https://docs.moonbitlang.cn/toolchain/moonide/index.html#moon-ide-find-references-track-all-usages)
  - [`moon ide codelens` - 获取引用 CodeLens](https://docs.moonbitlang.cn/toolchain/moonide/index.html#moon-ide-codelens-get-reference-code-lenses)
  - [`moon ide outline` - 获取结构概览](https://docs.moonbitlang.cn/toolchain/moonide/index.html#moon-ide-outline-get-structural-overview)
  - [`moon ide doc` - 发现与探索 API](https://docs.moonbitlang.cn/toolchain/moonide/index.html#moon-ide-doc-discover-and-explore-apis)
- MoonBit VSCode 插件
  - [命令](https://docs.moonbitlang.cn/toolchain/vscode/index.html#commands)
  - [操作](https://docs.moonbitlang.cn/toolchain/vscode/index.html#actions)
  - [代码透镜](https://docs.moonbitlang.cn/toolchain/vscode/index.html#code-lens)
- WebAssembly 集成
  - [组件模型](https://docs.moonbitlang.cn/toolchain/wasm/index.html#component-model)
  - [自定义导出和导入](https://docs.moonbitlang.cn/toolchain/wasm/index.html#custom-export-and-import)
  - [问与答](https://docs.moonbitlang.cn/toolchain/wasm/index.html#q-a)

# Moon 构建系统

目录：

- MoonBit 构建系统教程
  - [先决条件](https://docs.moonbitlang.cn/toolchain/moon/tutorial.html#prerequisites)
  - [创建一个新模块](https://docs.moonbitlang.cn/toolchain/moon/tutorial.html#creating-a-new-module)
  - [理解模块目录结构](https://docs.moonbitlang.cn/toolchain/moon/tutorial.html#understanding-the-module-directory-structure)
  - [使用包](https://docs.moonbitlang.cn/toolchain/moon/tutorial.html#working-with-packages)
  - [选择目标后端](https://docs.moonbitlang.cn/toolchain/moon/tutorial.html#choosing-a-target)
  - [包导入](https://docs.moonbitlang.cn/toolchain/moon/tutorial.html#package-importing)
  - [创建和使用新包](https://docs.moonbitlang.cn/toolchain/moon/tutorial.html#creating-and-using-a-new-package)
  - [添加测试](https://docs.moonbitlang.cn/toolchain/moon/tutorial.html#adding-tests)
- 运行 `.mbtx` 脚本
  - [运行 `.mbtx` 文件](https://docs.moonbitlang.cn/toolchain/moon/script-mode.html#run-a-mbtx-file)
  - [测试 `.mbtx` 脚本](https://docs.moonbitlang.cn/toolchain/moon/script-mode.html#test-a-mbtx-script)
  - [从 stdin 运行 `.mbtx` 脚本](https://docs.moonbitlang.cn/toolchain/moon/script-mode.html#run-a-mbtx-script-from-stdin)
- 使用与发布包
  - [设置 mooncakes.io 账户](https://docs.moonbitlang.cn/toolchain/moon/package-manage-tour.html#setup-mooncakes-io-account)
  - [设置 MoonBit 项目](https://docs.moonbitlang.cn/toolchain/moon/package-manage-tour.html#setup-moonbit-project)
  - [添加依赖](https://docs.moonbitlang.cn/toolchain/moon/package-manage-tour.html#add-dependencies)
  - [从模块导入包](https://docs.moonbitlang.cn/toolchain/moon/package-manage-tour.html#import-packages-from-module)
  - [移除依赖](https://docs.moonbitlang.cn/toolchain/moon/package-manage-tour.html#remove-dependencies)
  - [发布你的模块](https://docs.moonbitlang.cn/toolchain/moon/package-manage-tour.html#publish-your-module)
- 工作区支持
  - [初始化工作区](https://docs.moonbitlang.cn/toolchain/moon/workspace.html#initialize-a-workspace)
  - [添加成员](https://docs.moonbitlang.cn/toolchain/moon/workspace.html#add-members)
  - [在工作区根目录工作](https://docs.moonbitlang.cn/toolchain/moon/workspace.html#work-at-workspace-root)
  - [同步成员版本](https://docs.moonbitlang.cn/toolchain/moon/workspace.html#sync-member-versions)
- `moon`的命令行帮助
  - [`moon`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon)
  - [`moon new`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-new)
  - [`moon build`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-build)
  - [`moon check`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-check)
  - [`moon run`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-run)
  - [`moon test`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-test)
  - [`moon clean`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-clean)
  - [`moon fmt`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-fmt)
  - [`moon doc`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-doc)
  - [`moon info`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-info)
  - [`moon bench`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-bench)
  - [`moon add`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-add)
  - [`moon remove`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-remove)
  - [`moon install`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-install)
  - [`moon tree`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-tree)
  - [`moon login`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-login)
  - [`moon register`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-register)
  - [`moon publish`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-publish)
  - [`moon package`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-package)
  - [`moon update`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-update)
  - [`moon coverage`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-coverage)
  - [`moon coverage analyze`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-coverage-analyze)
  - [`moon coverage report`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-coverage-report)
  - [`moon coverage clean`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-coverage-clean)
  - [`moon generate-build-matrix`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-generate-build-matrix)
  - [`moon upgrade`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-upgrade)
  - [`moon shell-completion`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-shell-completion)
  - [`moon version`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-version)
- 模块配置
  - [名称](https://docs.moonbitlang.cn/toolchain/moon/module.html#name)
  - [版本](https://docs.moonbitlang.cn/toolchain/moon/module.html#version)
  - [依赖管理](https://docs.moonbitlang.cn/toolchain/moon/module.html#dependency-management)
  - [元信息](https://docs.moonbitlang.cn/toolchain/moon/module.html#meta-information)
  - [使用 `.moonignore` 控制发布文件](https://docs.moonbitlang.cn/toolchain/moon/module.html#publishing-files-with-moonignore)
  - [首选目标](https://docs.moonbitlang.cn/toolchain/moon/module.html#preferred-target)
  - [支持的目标](https://docs.moonbitlang.cn/toolchain/moon/module.html#supported-targets)
  - [源目录](https://docs.moonbitlang.cn/toolchain/moon/module.html#source-directory)
  - [警告列表](https://docs.moonbitlang.cn/toolchain/moon/module.html#warning-list)
  - [Rule](https://docs.moonbitlang.cn/toolchain/moon/module.html#rule)
  - [脚本](https://docs.moonbitlang.cn/toolchain/moon/module.html#scripts)
- 包配置
  - [新格式（`moon.pkg`）](https://docs.moonbitlang.cn/toolchain/moon/package.html#new-format-moon-pkg)
  - [名称](https://docs.moonbitlang.cn/toolchain/moon/package.html#name)
  - [格式化](https://docs.moonbitlang.cn/toolchain/moon/package.html#formatter)
  - [包类型](https://docs.moonbitlang.cn/toolchain/moon/package.html#package-type)
  - [is-main（已弃用）](https://docs.moonbitlang.cn/toolchain/moon/package.html#is-main-deprecated)
  - [导入依赖](https://docs.moonbitlang.cn/toolchain/moon/package.html#importing-dependencies)
  - [最大并发测试数](https://docs.moonbitlang.cn/toolchain/moon/package.html#maximum-concurrent-tests)
  - [条件编译](https://docs.moonbitlang.cn/toolchain/moon/package.html#conditional-compilation)
  - [支持的目标](https://docs.moonbitlang.cn/toolchain/moon/package.html#supported-targets)
  - [原生存根文件](https://docs.moonbitlang.cn/toolchain/moon/package.html#native-stub-files)
  - [链接选项](https://docs.moonbitlang.cn/toolchain/moon/package.html#link-options)
  - [Rule 和 dev_build](https://docs.moonbitlang.cn/toolchain/moon/package.html#rule-and-dev-build)
  - [警告列表](https://docs.moonbitlang.cn/toolchain/moon/package.html#warnings-list)
  - [虚拟包](https://docs.moonbitlang.cn/toolchain/moon/package.html#virtual-package)
- 测量代码覆盖率
  - [在测试中运行代码覆盖率](https://docs.moonbitlang.cn/toolchain/moon/coverage.html#running-code-coverage-in-tests)
  - [可视化覆盖率结果](https://docs.moonbitlang.cn/toolchain/moon/coverage.html#visualizing-the-coverage-results)
  - [跳过覆盖检查](https://docs.moonbitlang.cn/toolchain/moon/coverage.html#skipping-coverage)

# MoonBit 构建系统教程

Moon 是 MoonBit 语言的构建系统，目前基于 [n2](https://github.com/evmar/n2) 项目。Moon 支持并行和增量构建。此外，moon 还在 [mooncakes.io](https://mooncakes.io/) 上管理和构建第三方包。

## 先决条件

在开始本教程之前，请确保你已安装以下内容：

1. **MoonBit CLI 工具**：从 https://www.moonbitlang.cn/download/ 下载。这个命令行工具用于创建和管理 MoonBit 项目。

   使用 `moon help` 查看使用说明。

   ```
   $ moon help
   ...
   ```

   

2. Visual Studio Code 中的 **MoonBit 语言** 插件：你可以从 VS Code 市场安装。此插件为 MoonBit 提供了丰富的开发环境，包括语法高亮、代码补全等功能。

一旦你满足了这些先决条件，我们就可以开始创建一个新的 MoonBit 模块。

## 创建一个新模块

要创建一个新模块，在终端中输入 `moon new <path>` 命令，其中 path 是你想要创建项目的文件夹目录，之后项目会被创建。使用默认值，你会在 `my_project` 目录中创建一个名为 `username/my_project` 的新模块。

```
$ moon new my_project
Initialized empty Git repository in my_project/.git/
Created username/my_project at my_project
```



你也可以通过使用 `--user` 选项和 `--name` 选项分别指定用户名和模块名称。如果你已经登录，用户名将默认为你的用户名。

## 理解模块目录结构

创建新模块后，你的目录结构应该如下：

```
my_project
├── Agents.md
├── cmd
│   └── main
│       ├── main.mbt
│       └── moon.pkg
├── LICENSE
├── moon.mod
├── moon.pkg
├── my_project_test.mbt
├── my_project.mbt
├── README.mbt.md
└── README.md -> README.mbt.md
```



备注

在 Windows 系统上，你需要管理员权限或启用开发者模式才能创建符号链接。

以下是目录结构的简要说明：

- `moon.mod` 用于标识目录为 MoonBit 模块。它包含模块名称、版本等元数据。

  ```
  name = "username/my_project"
  version = "0.1.0"
  readme = "README.mbt.md"
  repository = ""
  license = "Apache-2.0"
  keywords = []
  description = ""
  ```

  

- `.` 和 `cmd/main` 目录：这些是模块中的包。每个包可以包含多个 `.mbt` 文件，这些文件是 MoonBit 语言的源代码文件。但是，无论一个包有多少 `.mbt` 文件，它们都共享同一个 `moon.pkg` 文件。较旧的项目仍然可能使用遗留的 `moon.pkg.json` 格式。`*_test.mbt` 是包中的独立测试文件，这些文件用于黑盒测试，因此同一个包的私有成员不能直接访问。

- `moon.pkg` 是包描述符。它定义了包的属性，例如它是否是 main 包以及它导入的包。

  - `cmd/main/moon.pkg`：

    ```
    import {
      "username/my_project" @lib,
    }
    
    pkgtype(kind: "executable")
    ```

    

    这里，`pkgtype(kind: "executable")` 表示该包包含 `moon run` 命令的入口。

  - `moon.pkg`：

    这个文件可以是空的。它的作用只是告诉构建系统这个文件夹是一个包。

- `README.mbt.md` 是 README 文件。在这个文件里，`mbt check` 代码块会由 `moon check` 和 `moon test` 进行检查和运行。

## 使用包

我们的 `username/my_project` 模块包含两个包：`username/my_project` 和 `username/my_project/cmd/main`。

`username/my_project` 包包含 `my_project.mbt` 和 `my_project_test.mbt` 文件：

my_project.mbt

```
///|
pub fn fib(n : Int32) -> Int64 {
  for i = 0, a = 0L, b = 1L; i < n; i = i + 1, a = b, b = a + b {

  } nobreak {
    b
  }
}
```



my_project_test.mbt

```
///|
test "fib" {
  let array = [1, 2, 3, 4, 5].map(fib(_))

  // `inspect` 用于检查函数输出
  // 只需写 `inspect(value)`，然后执行 `moon test --update`
  // 即可更新预期输出，并在之后进行校验
  inspect(array, content="[1, 2, 3, 5, 8]")
}
```



备注

生成的文件名取决于包名。

`username/my_project/cmd/main` 包包含一个 `main.mbt` 文件：

```
///|
fn main {
  println(@lib.fib(10))
}
```



要执行程序，在 `moon run` 命令中指定文件系统路径到 `username/my_project/cmd/main` 包：

```
$ moon run cmd/main
89
```



你可以使用 `moon test` 命令进行测试：

```
$ moon test
Total tests: 1, passed: 1, failed: 0.
```



## 选择目标后端

Moon 有三个与目标后端相关的配置项，它们分别负责不同的事情：

- 命令行上的 `--target` 用于选择当前命令使用哪个后端
- `moon.mod` 中的 `preferred_target` 用于为 `moon` 和语言服务器选择默认后端
- `supported_targets` 用于声明一个模块或包打算支持哪些后端

例如，一个以 native 为主的 CLI 项目可以这样设置：

```
preferred_target = "native"
supported_targets = "native"
```



`supported_targets` 使用目标集合语法，例如 `js`、`+js+wasm-gc` 或 `+all-js`。

如果只有部分文件与后端相关，就让模块或包的元数据保持宽泛，并使用 `moon.pkg` 或遗留的 `moon.pkg.json` 中的 [`targets`](https://docs.moonbitlang.cn/toolchain/moon/package.html#conditional-compilation) 按后端选择文件。

## 包导入

在 MoonBit 构建系统中，依赖是在包级别声明的。要在 `username/my_project/cmd/main` 中导入 `username/my_project` 包，你需要在 `cmd/main/moon.pkg` 中指定：

```
import {
  "username/my_project" @lib,
}

pkgtype(kind: "executable")
```



这里，`"username/my_project"` 表示导入根包，并为它指定别名 `lib`，因此你可以在 `cmd/main/main.mbt` 中使用 `@lib.fib(10)`。

## 创建和使用新包

首先，在模块根目录下创建一个名为 `fib` 的新目录：

```
mkdir fib
```



现在，你可以在 `fib` 下创建新文件：

slow.mbt

```
pub fn fib_slow(n : Int32) -> Int32 {
  match n {
    0 => 0
    1 => 1
    _ => fib_slow(n - 1) + fib_slow(n - 2)
  }
}
```



fast.mbt

```
pub fn fib_fast(num : Int32) -> Int32 {
  fn aux(n, acc1, acc2) {
    match n {
      0 => acc1
      1 => acc2
      _ => aux(n - 1, acc2, acc1 + acc2)
    }
  }

  aux(num, 0, 1)
}
```



moon.pkg

```
// 这个包暂时不需要额外配置。
```



在创建这些文件后，你的目录结构应该如下：

```
.
├── Agents.md
├── cmd
│   └── main
│       ├── main.mbt
│       └── moon.pkg
├── fib
│   ├── fast.mbt
│   ├── moon.pkg
│   └── slow.mbt
├── LICENSE
├── moon.mod
├── moon.pkg
├── my_project_test.mbt
├── my_project.mbt
├── README.mbt.md
└── README.md -> README.mbt.md
```



在 `cmd/main/moon.pkg` 文件中，导入 `username/my_project/fib` 包并将其别名定制为 `my_awesome_fibonacci`：

```
import {
  "username/my_project/fib" @my_awesome_fibonacci,
}

pkgtype(kind: "executable")
```



这会导入 `fib` 包。完成之后，你就可以在 `cmd/main/main.mbt` 中使用 `fib` 包了。将 `cmd/main/main.mbt` 的内容替换为：

```
fn main {
  let a = @my_awesome_fibonacci.fib_slow(10)
  let b = @my_awesome_fibonacci.fib_fast(11)
  println("fib(10) = \{a}, fib(11) = \{b}")
}
```



为了执行你的程序，指定 main 包的路径：

```
$ moon run cmd/main
fib(10) = 55, fib(11) = 89
```



## 添加测试

让我们添加一些测试来验证我们的 fib 实现。在 `fib/fib_test.mbt` 中添加以下内容：

```
test {
  inspect(@fib.fib_slow(0))
  inspect(@fib.fib_slow(1))
  inspect(@fib.fib_slow(2))
}
```



这段代码测试斐波那契数列的前三项。`test { ... }` 定义了一个内联测试块。内联测试块中的代码在测试模式下执行。

内联测试块在非测试编译模式（`moon build` 和 `moon run`）中被丢弃，因此它们不会导致生成的代码大小膨胀。

这里我们使用了快照测试。执行 `moon test --update`，文件应该被更改为：

```
test {
  inspect(@fib.fib_slow(0), content="0")
  inspect(@fib.fib_slow(1), content="1")
  inspect(@fib.fib_slow(2), content="1")
}
```



注意，测试代码使用 `@fib` 来引用 `fib` 包。构建系统通过使用以 `_test.mbt` 结尾的文件自动为黑盒测试创建一个新包。

最后，使用 `moon test` 命令，它会扫描整个项目，识别并运行所有测试。如果一切正常，你将看到：

```
$ moon test
Total tests: 2, passed: 2, failed: 0.
```

# 行 `.mbtx` 脚本

Moon 构建系统支持直接编写 MoonBit 脚本，无需模块或包配置文件。脚本文件使用 `.mbtx` 扩展名。

## 运行 `.mbtx` 文件

编写脚本 `script.mbtx`：

```
///|
import {
  "moonbitlang/core/list" @ls
}

///|
async fn main {
  let xs = @ls.List(["1", "2", "3"])
  debug(xs)
}
```



然后直接运行该脚本：

```
$ moon run script.mbtx
```



在 `.mbtx` 中，你可以在文件顶部声明导入，语法与包配置相同。不同之处在于：导入路径可以在模块名后可选地包含版本 `@version`：

```
///|
import {
  "moonbitlang/async@0.20.2/fs",
  "moonbitlang/async@0.20.2",
}

///|
async fn main {
  ...
}
```



来自同一模块的所有导入包必须使用相同版本。

如果导入路径没有显式指定版本，则会使用本地索引中的最新版本。

脚本可以在导入后添加 `*`，将该包中的所有定义引入当前作用域。还可以用 `@alias` 为该导入设置自定义包别名：

```
///|
import {
  "moonbitlang/core/queue" @q *
}

///|
fn main {
  let queue = Queue([1, 2, 3])
  println(queue.length())
  let qualified = @q.Queue([4, 5])
  println(qualified.length())
}
```



包别名仍然可用，因此示例可以同时使用 `Queue` 和 `@q.Queue`。未显式指定 `@alias` 时，使用包的默认别名。全量导入语法仅限 `.mbtx` 脚本；普通包应使用包别名或 `using` 声明。当名称冲突会让脚本难以阅读时，优先使用显式导入。

## 测试 `.mbtx` 脚本

将脚本路径传给 `moon test`，即可单独测试该脚本：

```
moon test script.mbtx
```



脚本必须定义 `fn main`，但生成的测试入口不会运行它。即使脚本位于项目内，显式传入 `.mbtx` 路径也只会测试该脚本；反过来，对整个包运行测试时不会包含 `.mbtx` 脚本。

## 从 stdin 运行 `.mbtx` 脚本

Moon 支持从 stdin 运行 `.mbtx` 脚本：

```
$ cat script.mbtx | moon run -
```



对于简短脚本，可以使用 `-c` 直接传入 `.mbtx` 源码：

```
$ moon run -c "<script>"
$ moon run -c 'fn main { println("hello") }'
```



你也可以使用 heredoc（由 shell 提供的一项功能）：

```
$ moon run - <<EOF
fn main {
  println("hello")
}
EOF
```

# 使用与发布包

MoonBit 的构建系统无缝集成了包管理与文档生成工具，让用户可以轻松从 [mooncakes.io](https://mooncakes.io/) 获取依赖、访问模块文档并发布新模块。

在开始之前，请确保你已经安装了 [moon](https://www.moonbitlang.com/download/)。

## 设置 mooncakes.io 账户

备注

如果你不需要发布，可以跳过此步骤。

如果你没有 mooncakes.io 账户，请运行 `moon register` 并按照指南操作。如果你之前注册过账户，可以使用 `moon login` 登录。

当你看到以下消息时，表示你已成功登录：

```
API token saved to ~/.moon/credentials.json
```



## 设置 MoonBit 项目

打开现有项目，或通过 `moon new <PATH>` 创建新项目。例如：

```
$ moon new .
Created username/myapp at .
```



它会在该路径下生成模板文件：

```
├── AGENTS.md                    # Agent 协作指南
├── LICENSE                      # 开源许可证 
├── README.mbt.md                # 带 MoonBit 类型检查支持的 README 文件 
├── README.md -> README.mbt.md   # 为需要 README.md 的平台提供的符号链接
├── cmd                           
│   └── main                     
│       ├── main.mbt             # MoonBit 源文件 
│       └── moon.pkg             # username/myapp/cmd/main 包的配置文件
├── moon.mod                     # username/myapp 模块配置
├── moon.pkg                     # username/myapp 包配置文件
├── myapp.mbt                    # MoonBit 源文件
├── myapp_test.mbt               # 黑盒测试
└── myapp_wbtest.mbt             # 白盒测试
```



`moon new <PATH>` 会生成一个包含两个包的起始模块。模块是包含多个包的发布单元。包表示一个命名空间和编译单元，由包配置文件定义，并包含同目录下的 `.mbt` 文件。

模块和包通过一种特殊路径标识（不是文件系统路径）。例如：

```
username/myapp/cmd/main
─────────────────┬─────
────────┬─────   │
        │        │
        │        └─ 位于 `username/myapp` 模块下的包 `username/myapp/cmd/main`
        │
        └────────── 模块路径，同时也定义了包 `username/myapp`
```



默认模板包含测试文件、文档和协作元数据。你可以安全删除任何不需要的模板文件。下面同样是一个有效的 MoonBit 项目：

```
├── moon.mod
├── moon.pkg
└── source.mbt
```



## 添加依赖

You can browse all available modules on [mooncakes.io](https://mooncakes.io/). Use `moon add` to add the dependencies you need, or manually edit the `import` declaration in `moon.mod`.

例如，要添加 [moonbit-community/starter](https://mooncakes.io/docs/moonbit-community/starter) 模块的最新版本：

```
$ moon add moonbit-community/starter
```



备注

Moon 也支持本地依赖。详见 [依赖管理](https://docs.moonbitlang.cn/toolchain/moon/module.html#dependency-management)。

## 从模块导入包

`moonbit-community/starter` 模块包含一个 `moonbit-community/starter/rabbit` 包。

把 [moonbit-community/starter](https://mooncakes.io/docs/moonbit-community/starter) 模块添加为依赖后，如果要在 `username/myapp/cmd/main` 包中使用 `moonbit-community/starter/rabbit` 包，你需要先导入它：

```
// add this import to `cmd/main/moon.pkg`
import {
  "moonbit-community/starter/rabbit"
}

pkgtype(kind: "executable")
```



备注

你还可以给导入的包起一个别名：

```
import {
  "moonbit-community/starter/rabbit" @alias
}
```



现在你可以调用 `rabbit` 包中的 `hello` 函数：

```
// 在 `cmd/main/main.mbt` 中
fn main {
  // println("hello")
  @rabbit.hello()
}
```



运行你的主包，查看终端输出。

```
$ moon run cmd/main
```



## 移除依赖

你可以通过 `moon remove <模块名>` 移除依赖。

## 发布你的模块

如果你准备分享你的模块，使用 `moon publish` 将模块推送到 mooncakes.io。在发布之前有一些重要的注意事项需要记住：

### 语义化版本约定

MoonBit 的包管理遵循 [语义化版本](https://semver.org/) 约定。每个模块必须以 `MAJOR.MINOR.PATCH` 格式定义一个版本号。每次推送，模块必须递增：

- 当你进行不兼容的 API 更改时，递增 MAJOR 版本
- 在向后兼容的方式下添加功能时，递增 MINOR 版本
- 在进行向后兼容的错误修复时，递增 PATCH 版本

附加的预发布和构建元数据标签可作为 `MAJOR.MINOR.PATCH` 格式的扩展。

moon 实现了 [最小版本选择](https://research.swtch.com/vgo-mvs)，根据模块的语义化版本信息自动处理和安装依赖。最小版本选择假定每个模块声明自己的依赖要求，并遵循语义化版本约定，旨在使用户的依赖图尽可能接近作者的开发时依赖。

### 自述文件 & 元数据

`moon.mod` 和 `README.md` 中的元数据将显示在 mooncakes.io 上。

元数据包括以下部分：

- `license`：此模块的许可证，遵循 [SPDX](https://spdx.dev/about/overview/) 约定
- `keywords`：此模块的关键字
- `repository`：包源代码仓库的 URL
- `description`：此模块的简短描述
- `homepage`：模块主页的 URL

# 工作区支持

Moon 工作区支持让你在一个仓库中通过一个工作区清单（`moon.work`）管理多个模块。

## 初始化工作区

假设目录结构如下：

```
repo/
  mod_a/
    moon.mod
  mod_b/
    moon.mod
```



在 `repo/` 下，初始化工作区并注册成员模块：

```
moon work init mod_a mod_b
```



这会创建 `moon.work`：

```
members = [
  "./mod_a",
  "./mod_b",
]
```



## 添加成员

添加新模块后，可用以下命令将其注册到工作区：

```
moon work use mod_c
```



## 在工作区根目录工作

配置好 `moon.work` 后，可在工作区根目录执行 `moon` 命令：

```
moon check --target all
moon test --target all
moon info
moon clean
```



这些命令会在工作区上下文中运行，而不是仅针对单个模块。

有些命令只适用于模块（例如 `publish`）。对于这类命令，请在具体成员模块目录中执行：

```
moon -C mod_a publish
```



## 同步成员版本

如果某个成员依赖了另一个工作区成员的过期版本（例如 `mod_a@0.1.0`，而工作区中的 `mod_a` 已是 `0.2.0`），请执行：

```
moon work sync
```



这会更新成员的 `moon.mod` 文件，使工作区成员版本保持一致。

# `moon`的命令行帮助

本文档包含`moon`命令行程序的帮助内容。

提示

要获取最新的手册，请查看 [moon 的仓库](https://github.com/moonbitlang/moon/blob/main/docs/manual/src/commands.md)

**命令概述：**

- [`moon`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon)
- [`moon new`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-new)
- [`moon build`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-build)
- [`moon check`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-check)
- [`moon run`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-run)
- [`moon test`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-test)
- [`moon clean`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-clean)
- [`moon fmt`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-fmt)
- [`moon doc`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-doc)
- [`moon info`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-info)
- [`moon bench`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-bench)
- [`moon add`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-add)
- [`moon remove`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-remove)
- [`moon install`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-install)
- [`moon tree`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-tree)
- [`moon login`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-login)
- [`moon register`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-register)
- [`moon publish`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-publish)
- [`moon package`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-package)
- [`moon update`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-update)
- [`moon coverage`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-coverage)
- [`moon coverage analyze`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-coverage-analyze)
- [`moon coverage report`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-coverage-report)
- [`moon coverage clean`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-coverage-clean)
- [`moon generate-build-matrix`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-generate-build-matrix)
- [`moon upgrade`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-upgrade)
- [`moon shell-completion`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-shell-completion)
- [`moon version`↴](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-version)

## `moon`

**用法：** `moon <命令>`

**子命令：**

- `new` — 创建一个新的 MoonBit 模块
- `build` — 构建当前包
- `check` — 检查当前包，但不构建对象文件
- `run` — 运行一个 main 包
- `test` — 测试当前包
- `clean` — 删除 _build 目录
- `fmt` — 格式化源代码
- `doc` — 生成文档或搜索符号文档
- `info` — 为模块中的所有包生成公共接口（`.mbti`）文件
- `bench` — 对当前包运行基准测试
- `add` — 添加一个依赖
- `remove` — 移除一个依赖
- `install` — 安装依赖
- `tree` — 显示依赖树
- `login` — 登录到您的账户
- `register` — 在 mooncakes.io 注册一个账户
- `publish` — 发布当前模块
- `package` — 打包当前模块
- `update` — 更新包注册表索引
- `coverage` — 代码覆盖率工具
- `generate-build-matrix` — 生成用于基准测试的构建矩阵（遗留功能）
- `upgrade` — 升级工具链
- `shell-completion` — 为 bash/elvish/fish/pwsh/zsh 生成 shell 补全并输出到标准输出
- `version` — 打印版本信息并退出

## `moon new`

创建一个新的 MoonBit 模块

**用法：** `moon new [选项] <路径>`

**参数：**

- `<PATH>` — 新项目的路径

**选项：**

- `--user <用户>` — 包的开发者名称。默认为已登录用户的用户名
- `--name <名称>` — 包的名称。默认为路径的最后一部分

## `moon build`

构建当前包

**用法：** `moon build [选项]`

**选项：**

- `--std` — 启用标准库（默认）

- `--nostd` — 禁用标准库

- `-g`, `--debug` — 发出调试信息

- `--release` — 在发布模式下编译

- `--strip` — 删除调试信息

- `--no-strip` — 不删除调试信息

- `--target <目标>` — 选择输出目标

  可能的值：`wasm`，`wasm-gc`，`js`，`native`，`llvm`，`all`

- `--enable-coverage` — 启用覆盖率指令

- `--sort-input` — 排序输入文件

- `--output-wat` — 输出 WAT 而不是 WASM

- `-d`, `--deny-warn` — 将所有警告视为错误

- `--no-render` — 不要从 moonc 渲染诊断（不要将 '-error-format json' 传递给 moonc）

- `--warn-list <WARN_LIST>` — 警告列表配置

- `--alert-list <ALERT_LIST>` — 警报列表配置

- `-j`，`--jobs <作业数>` — 设置要并行运行的最大作业数

- `--render-no-loc <最低级别>` — 从某个级别开始渲染无位置的诊断

  默认值：`error`

  可能的值：`info`，`warn`，`error`

- `--frozen` — 不同步依赖项，假设本地依赖项是最新的

- `-w`, `--watch` — 监视文件系统并自动构建制品

## `moon check`

检查当前包，但不构建对象文件

**用法：** `moon check [选项] [单文件路径]`

**参数：**

- `<单文件路径>` — 检查单个文件（.mbt 或 .mbt.md）

**选项：**

- `--std` — 启用标准库（默认）

- `--nostd` — 禁用标准库

- `-g`, `--debug` — 发出调试信息

- `--release` — 在发布模式下编译

- `--strip` — 删除调试信息

- `--no-strip` — 不删除调试信息

- `--target <目标>` — 选择输出目标

  可能的值：`wasm`，`wasm-gc`，`js`，`native`，`llvm`，`all`

- `--enable-coverage` — 启用覆盖率指令

- `--sort-input` — 排序输入文件

- `--output-wat` — 输出 WAT 而不是 WASM

- `-d`, `--deny-warn` — 将所有警告视为错误

- `--no-render` — 不要从 moonc 渲染诊断（不要将 '-error-format json' 传递给 moonc）

- `--warn-list <WARN_LIST>` — 警告列表配置

- `--alert-list <ALERT_LIST>` — 警报列表配置

- `-j`，`--jobs <作业数>` — 设置要并行运行的最大作业数

- `--render-no-loc <最低级别>` — 从某个级别开始渲染无位置的诊断

  默认值：`error`

  可能的值：`info`，`warn`，`error`

- `--output-json` — 以 json 格式输出

- `--frozen` — 不同步依赖项，假设本地依赖项是最新的

- `-w`, `--watch` — 监视文件系统并自动检查文件

- `-p`，`--package-path <包路径>` — 要检查的包（及其依赖项）

- `--patch-file <PATCH_FILE>` — 要检查的补丁文件，仅在检查指定包时有效

- `--no-mi` — 是否跳过 mi 生成，仅在检查指定包时有效

- `--explain` — 是否使用详细信息解释错误代码

## `moon run`

`run` — 运行一个 main 包

**用法：** `moon run [选项] <包或 mbt 文件> [参数]...`

**参数：**

- `<包或 MoonBit 文件>` — 要运行的包或 .mbt 文件
- `<参数>` — 提供给要运行的程序的参数

**选项：**

- `--std` — 启用标准库（默认）

- `--nostd` — 禁用标准库

- `-g`, `--debug` — 发出调试信息

- `--release` — 在发布模式下编译

- `--strip` — 删除调试信息

- `--no-strip` — 不删除调试信息

- `--target <目标>` — 选择输出目标

  可能的值：`wasm`，`wasm-gc`，`js`，`native`，`llvm`，`all`

- `--enable-coverage` — 启用覆盖率指令

- `--sort-input` — 排序输入文件

- `--output-wat` — 输出 WAT 而不是 WASM

- `-d`, `--deny-warn` — 将所有警告视为错误

- `--no-render` — 不要从 moonc 渲染诊断（不要将 '-error-format json' 传递给 moonc）

- `--warn-list <WARN_LIST>` — 警告列表配置

- `--alert-list <ALERT_LIST>` — 警报列表配置

- `-j`，`--jobs <作业数>` — 设置要并行运行的最大作业数

- `--render-no-loc <最低级别>` — 从某个级别开始渲染无位置的诊断

  默认值：`error`

  可能的值：`info`，`warn`，`error`

- `--frozen` — 不同步依赖项，假设本地依赖项是最新的

- `--build-only` — 仅构建，不运行代码

## `moon test`

测试当前包

**用法：** `moon test [选项] [单文件路径]`

**参数：**

- `<单文件路径>` — 在单个文件中运行测试（.mbt 或 .mbt.md）

**选项：**

- `--std` — 启用标准库（默认）

- `--nostd` — 禁用标准库

- `-g`, `--debug` — 发出调试信息

- `--release` — 在发布模式下编译

- `--strip` — 删除调试信息

- `--no-strip` — 不删除调试信息

- `--target <目标>` — 选择输出目标

  可能的值：`wasm`，`wasm-gc`，`js`，`native`，`llvm`，`all`

- `--enable-coverage` — 启用覆盖率指令

- `--sort-input` — 排序输入文件

- `--output-wat` — 输出 WAT 而不是 WASM

- `-d`, `--deny-warn` — 将所有警告视为错误

- `--no-render` — 不要从 moonc 渲染诊断（不要将 '-error-format json' 传递给 moonc）

- `--warn-list <WARN_LIST>` — 警告列表配置

- `--alert-list <ALERT_LIST>` — 警报列表配置

- `-j`，`--jobs <作业数>` — 设置要并行运行的最大作业数

- `--render-no-loc <最低级别>` — 从某个级别开始渲染无位置的诊断

  默认值：`error`

  可能的值：`info`，`warn`，`error`

- `-p`, `--package <包>` — 在指定的包中运行测试

- `-f`, `--file <文件>` — 在指定的文件中运行测试。仅在指定了 `--package` 时有效

- `-i`, `--index <索引>` — 仅在文件中运行第 index 个测试。仅在指定了 `--file` 时有效

- `--doc-index <文档索引>` — 仅在文件中运行第 index 个文档测试。仅在指定了 `--file` 时有效

- `-u`, `--update` — 更新测试快照

- `-l`, `--limit <限制>` — 限制期望测试更新通过的运行次数，以避免无限循环

  默认值：`256`

- `--frozen` — 不同步依赖项，假设本地依赖项是最新的

- `--build-only` — 仅构建，不运行测试

- `--no-parallelize` — 顺序运行目标后端中的测试

- `--test-failure-json` — 以 JSON 格式打印失败消息

- `--patch-file <补丁文件>` — 补丁文件的路径

- `--doc` — 运行文档测试

## `moon clean`

删除 _build 目录

**用法：** `moon clean`

## `moon fmt`

格式化源代码

**用法：** `moon fmt [选项] [参数]...`

**参数：**

- `<参数>`

**选项：**

- `--check` — 仅检查，不更改源代码

- `--sort-input` — 排序输入文件

- `--block-style <块样式>` — 在每个段之间添加分隔符

  可能的值：`false`，`true`

## `moon doc`

生成文档或搜索符号文档

**用法：** `moon doc [选项] [符号]`

**参数：**

- `<符号>` — [已废弃] 要查询文档的符号。请改用 `moon ide doc <SYMBOL>`。

**选项：**

- `--serve` — 启动一个 Web 服务器来提供文档

- `-b`, `--bind <绑定>` — 服务器的地址

  默认值：`127.0.0.1`

- `-p`, `--port <端口>` — 服务器的端口

  默认值：`3000`

- `--frozen` — 不同步依赖项，假设本地依赖项是最新的

## `moon info`

为模块中的所有包生成公共接口（`.mbti`）文件

**用法：** `moon info [选项]`

**选项：**

- `--frozen` — 不同步依赖项，假设本地依赖项是最新的

- `--no-alias` — 不要使用别名来缩短输出中的包名

- `--target <目标>` — 选择输出目标

  可能的值：`wasm`，`wasm-gc`，`js`，`native`，`llvm`，`all`

- `-p`, `--package <包>` — 仅为指定的包生成 mbti 文件

## `moon bench`

在当前包中运行基准测试

**用法：** `moon bench [选项] [路径]...`

**参数：**

- `[路径]...` — 按文件系统路径运行基准测试。路径可以指向包目录，也可以指向包内的文件。

**选项：**

- `--std` — 启用标准库（默认）

- `--nostd` — 禁用标准库

- `-g`, `--debug` — 发出调试信息

- `--release` — 在发布模式下编译

- `--strip` — 删除调试信息

- `--no-strip` — 不删除调试信息

- `--target <目标>` — 选择输出目标

  可能的值：`wasm`，`wasm-gc`，`js`，`native`，`llvm`，`all`

- `--enable-coverage` — 启用覆盖率指令

- `--sort-input` — 排序输入文件

- `--output-wat` — 输出 WAT 而不是 WASM

- `-d`, `--deny-warn` — 将所有警告视为错误

- `--no-render` — 不要从 moonc 渲染诊断（不要将 '-error-format json' 传递给 moonc）

- `--warn-list <WARN_LIST>` — 警告列表配置

- `--alert-list <ALERT_LIST>` — 警报列表配置

- `-j`，`--jobs <作业数>` — 设置要并行运行的最大作业数

- `--render-no-loc <最低级别>` — 从某个级别开始渲染无位置的诊断

  默认值：`error`

  可能的值：`info`，`warn`，`error`

- `-p`, `--package <包>` — 在指定的包中运行测试

- `-f`, `--file <文件>` — 在指定的文件中运行测试。仅在指定了 `--package` 时有效

- `-i`, `--index <索引>` — 仅在文件中运行第 index 个测试。仅在指定了 `--file` 时有效

- `--frozen` — 不同步依赖项，假设本地依赖项是最新的

- `--build-only` — 仅构建，不运行基准测试

- `--no-parallelize` — 顺序执行目标后端中的基准测试

## `moon add`

添加一个依赖

**用法：** `moon add [选项] <包路径>`

**参数：**

- `<包路径>` — 要添加的包路径

**选项：**

- `--bin` — 是否将依赖项添加为二进制文件

## `moon remove`

移除一个依赖

**用法：** `moon remove <包路径>`

**参数：**

- `<包路径>` — 要移除的包路径

## `moon install`

安装依赖

**用法：** `moon install`

## `moon tree`

显示依赖树

**用法：** `moon tree`

## `moon login`

登录到您的账户

**用法：** `moon login`

## `moon register`

在 mooncakes.io 注册一个账户

**用法：** `moon register`

## `moon publish`

发布当前模块

**用法：** `moon publish [选项]`

**选项：**

- `--frozen` — 不同步依赖项，假设本地依赖项是最新的

## `moon package`

打包当前模块

**用法：** `moon package [选项]`

**选项：**

- `--frozen` — 不同步依赖项，假设本地依赖项是最新的
- `--list`

## `moon update`

更新包注册表索引

**用法：** `moon update`

## `moon coverage`

代码覆盖率工具

**用法：** `moon coverage <命令>`

**子命令：**

- `analyze` — 运行带有指令的测试并报告覆盖率
- `report` — 生成代码覆盖率报告
- `clean` — 清理覆盖率工件

## `moon coverage analyze`

运行带有指令的测试并报告覆盖率

**用法：** `moon coverage analyze [选项] [-- <额外标志>...]`

**参数：**

- `<额外标志>` — 直接传递给 `moon_cove_report` 的额外标志

**选项：**

- `-p`, `--package <包>` — 仅为指定的包生成测试覆盖率

## `moon coverage report`

生成代码覆盖率报告

**用法：** `moon coverage report [参数]... [命令]`

**参数：**

- `<参数>` — 要传递给覆盖率工具的参数

**选项：**

- `-h`, `--help` — 显示覆盖率工具的帮助

## `moon coverage clean`

清理覆盖率工件

**用法：** `moon coverage clean`

## `moon generate-build-matrix`

生成用于基准测试的构建矩阵（遗留功能）

**用法：** `moon generate-build-matrix [选项] --output-dir <输出目录>`

**选项：**

- `-n <数字>` — 将 `drow`、`dcol`、`mrow`、`mcol` 的所有值设置为相同的值
- `--drow <DIR_ROWS>` — 目录行数
- `--dcol <DIR_COLS>` — 目录列数
- `--mrow <MOD_ROWS>` — 模块行数
- `--mcol <MOD_COLS>` — 模块列数
- `-o`, `--output-dir <输出目录>` — 输出目录

## `moon upgrade`

升级工具链

**用法：** `moon upgrade [选项]`

**选项：**

- `-f`, `--force` — 强制升级
- `--dev` — 安装最新的开发版本

## `moon shell-completion`

为 bash/elvish/fish/pwsh/zsh 生成 shell 补全并输出到标准输出

**用法：** `moon shell-completion [选项]`

讨论：为 Bash、Elvish、Fish、Zsh 或 PowerShell 启用命令补全功能。该脚本的输出在标准输出（stdout）上，用户可以将输出重定向到自己选择的文件。文件的存放位置将取决于所使用的 shell 以及操作系统。具体的配置也可能决定这些脚本应放置在何处。

补全脚本不会自动更新，因此你可能需要定期运行此命令以获取最新的补全内容。或者，你可以将`eval "$(moon shell-completion --shell <SHELL>)"`添加到你所用 shell 的配置文件（rc file）中，这样每次启动 shell 时都会加载最新的补全内容。不过，这种方式被认为不如安装补全脚本高效。

以下是在 Unix 及类似操作系统（如 GNU/Linux）下，针对三种受支持的 shell 的一些常见设置。

Bash:

对于系统范围的命令，补全文件通常存放在 `/etc/bash_completion.d/`；而针对用户特定的命令，它们可存放在 `~/.local/share/bash - completion/completions`。运行以下命令：

```
$ mkdir -p ~/.local/share/bash-completion/completions
$ moon shell-completion --shell bash >> ~/.local/share/bash-completion/completions/moon
```



这会安装补全脚本。你可能需要注销并重新登录 shell 会话，以使更改生效。

Bash (macOS/Homebrew):

Homebrew 会将 bash 补全文件存储在 Homebrew 目录内。在安装了 `bash-completion` 的 Homebrew 软件包后，运行以下命令：

```
$ mkdir -p $(brew --prefix)/etc/bash_completion.d
$ moon shell-completion --shell bash > $(brew --prefix)/etc/bash_completion.d/moon.bash-completion
```



Fish:

Fish 补全文件通常存储在 `$HOME/.config/fish/completions` 目录下。运行以下命令：

```
$ mkdir -p ~/.config/fish/completions
$ moon shell-completion --shell fish > ~/.config/fish/completions/moon.fish
```



这会安装补全脚本。你可能需要注销并重新登录 shell 会话，以使更改生效。

Elvish:

Elvish 补全通常存放在单个 `completers` 模块中。常见的模块搜索路径是 `~/.config/elvish/lib`，运行以下命令：

```
$ moon shell-completion --shell elvish >> ~/.config/elvish/lib/completers.elv
```



将安装补全脚本。请注意使用`>>`（追加）而不是 `>`（覆盖），以防止覆盖其他命令的现有补全。然后在你的 rc.elv 文件前面添加：

```
`use completers`
```



以加载 `completers` 模块并启用补全功能。

Zsh:

ZSH 补全文件通常存放在 `$fpath` 变量所列出的任意目录中。要使用这些补全功能，你要么将生成的脚本添加到这些目录之一，要么将你自己的目录添加到这个列表中。

如果你不确定该使用哪个目录，添加一个自定义目录通常是最稳妥的做法。首先创建这个目录；在这个示例中，我们将在 `$HOME` 目录下创建一个隐藏目录：

```
$ mkdir ~/.zfunc
```



然后，在你的 `.zshrc` 文件里 `compinit` 命令之前添加以下几行：

```
fpath+=~/.zfunc
```



现在你可以使用以下命令来安装补全脚本

```
$ moon shell-completion --shell zsh > ~/.zfunc/_moon
```



然后，你必须开启一个新的 zsh 会话，或者直接运行

```
$ . ~/.zshrc
```



以便新的补全功能生效。

Custom locations:

另外，你可以将这些文件保存到你选择的位置，比如你家目录（$HOME）下的自定义目录。这样做的话，你需要添加合适的指令，例如在登录脚本中使用 `source`命令引入这些文件。请查阅你所使用 shell 的文档，了解如何添加此类指令。

PowerShell:

PowerShell 补全脚本需要 PowerShell 5.0 及更高版本（Windows 10 系统自带该版本，而 Windows 7 或 8.1 系统可单独下载）。

首先，检查是否已经设置了配置文件。

```
PS C:\> Test-Path $profile
```



如果上述命令返回 `False`，则运行以下命令。

```
PS C:\> New-Item -path $profile -type file -force
```



现在打开由 `$profile` 指定的文件（如果你使用了 `New-Item` 命令，该文件将是 `${env:USERPROFILE}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`）。

接下来，我们可以将补全文件保存到我们的配置文件中，或者保存到一个单独的文件里

```
PS C:\> moon shell-completion --shell powershell >>
${env:USERPROFILE}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```



这段讨论内容改编自 `rustup completions` 命令相关内容，并做了一些修改。

**选项：**

- `--shell <SHELL>` — 要为其生成补全的 shell

  默认值：`<您的 shell>`

  可能的值：`bash`, `elvish`, `fish`, `powershell`, `zsh`

## `moon version`

打印版本信息并退出

**用法：** `moon version [选项]`

**选项：**

- `--all` — 打印所有版本信息
- `--json` — 以 JSON 格式打印版本信息
- `--no-path` — 不打印路径

------

*本文档是由 [`clap-markdown`](https://crates.io/crates/clap-markdown) 自动生成的。*

# 模块配置

moon 使用模块文件来标识和描述一个模块。旧格式为 `moon.mod.json`，新格式为 `moon.mod`。完整的 JSON 模式请查看 [moon 的仓库](https://github.com/moonbitlang/moon/blob/main/crates/moonbuild/template/mod.schema.json)。

常规工具链命令不再接受 `moon.mod.json`。请先运行 `moon fmt`，将现有 JSON 配置文件迁移为 `moon.mod` 和 `moon.pkg`，再检查或构建项目。下方的 JSON 示例仅供迁移参考，不应作为新项目的配置。

`moon.mod` 的完整语法如下：

```
moon_mod ::= statement*
statement ::= import | assign | apply

import ::= "import" "{" (import_item ",")* import_item? "}" import_kind?
import_item ::= STRING

assign ::= LIDENT "=" expr

apply ::= LIDENT "(" (argument ",")* argument? ")"
argument ::= LIDENT ":" expr | STRING ":" expr  

expr ::= array | object | apply | STRING | INT | "true" | "false"
array ::= "[" (expr ",")* expr? "]"
object ::= "{" (field ",")* field? "}"
```



## 名称

`name` 字段用于指定模块的名称，它是必需的。

moon.mod

```
name = "user/example"
```



moon.mod.json

模块名称可以包含字母、数字、`_`、`-` 和 `/`。

对于发布到 [mooncakes.io](https://mooncakes.io/) 的模块，模块名称必须以用户名开头。

## 版本

`version` 字段用于指定模块的版本。

此字段是可选的。对于发布到 [mooncakes.io](https://mooncakes.io/) 的模块，版本号必须遵循 [语义化版本 2.0.0](https://semver.org/spec/v2.0.0.html) 规范。

moon.mod

```
version = "0.1.0"
```



moon.mod.json

## 依赖管理

模块依赖通过 `moon.mod` 中的 `import` 声明。遗留的 `moon.mod.json` 格式则使用 `deps` 字段表示相同信息。

它由 `moon add` 和 `moon remove` 等命令自动管理。

moon.mod

```
name = "username/hello"
import {
  "moonbitlang/x@0.4.6"
}
```



moon.mod.json

你也可以为模块使用本地依赖。

moon.mod

对于新的 `moon.mod` 格式，本地依赖配置已被弃用。推荐的本地依赖使用方式是在 `moon.work` 中配置。

例如，如果你使用 `moon.work` 管理 `user/module1` 和 `user/module2`：

```
// in moon.work
members = [
  "source/to/module1",
  "source/to/module2",
]
```



并且 `user/module1` 使用 `user/module2` 作为依赖：

```
// in source/to/module1/moon.mod
import {
  "user/module2@0.1.0"
}
```



`@version` 部分会被忽略，`user/module2` 会从本地源码解析，而不是从 mooncakes.io 解析。

moon.mod.json

## 元信息

### README

`readme` 字段用于指定模块的 README 文件的路径。

moon.mod

```
readme = "README.md"
```



moon.mod.json

### 仓库

`repository` 字段用于指定模块的仓库的 URL。

moon.mod

```
repository = "link/to/your/repo"
```



moon.mod.json

### 许可证

`license` 字段用于指定模块的许可证。许可证类型必须符合 [SPDX 许可证列表](https://spdx.org/licenses/)。

moon.mod

```
license = "MIT"
```



moon.mod.json

### 关键字

`keywords` 字段用于指定模块的关键字。

moon.mod

```
keywords = ["example", "test"]
```



moon.mod.json

### 描述

`description` 字段用于指定模块的描述。

moon.mod

```
description = "This is a description of the module."
```



moon.mod.json

## 使用 `.moonignore` 控制发布文件

使用 `.moonignore` 文件从 `moon package` 和 `moon publish` 创建的归档中排除文件和目录。每个文件使用 gitignore 风格的模式：

```
# Generated output
build/
*.log

# Keep this fixture even though other log files are excluded
!fixtures/expected.log

# Keep selected root dotfiles that are excluded by default
!/.gitignore
!/.moonignore

# Keep a hidden directory and everything below it
!/.well-known/
!/.well-known/**
```



发布时默认遵循 `.gitignore` 规则。如果某个目录包含 `.moonignore`，创建归档时将使用其规则代替同一目录中的 `.gitignore`；同一目录中的这两个文件不会合并。无论文件是否由 Git 跟踪，筛选都只依据这些模式。

不会读取 Git 仓库本地的 `.git/info/exclude` 和全局忽略配置。只有项目自身包含的忽略文件会影响归档，因此发布相同内容的结果不会依赖用户的 Git 配置。

默认情况下，各层级中名称以 `.` 开头的文件和目录都会被排除。上面锚定到根目录的示例会将两个忽略文件和 `.well-known/` 保留在归档中。重新包含一个目录并不会自动重新包含其内容，因此还需要第二条 `.well-known` 规则。

包根目录下的 `_build/` 始终会被排除，无法通过忽略规则或已弃用的 `include` 字段重新包含。此固定排除不适用于同名的嵌套目录。例如，`!/_build/` 和 `!/_build/**` 无法恢复包根目录下的 `_build/`，而 `examples/_build/data.bin` 不会仅仅因为所在的嵌套目录名为 `_build` 就被排除。

规则作用于包含忽略文件的目录及其所有后代。父目录继承来的规则仍然有效，而嵌套目录中后出现的匹配规则优先。这也包括用 `!` 恢复先前排除的路径、且该路径的父目录仍然可见的规则。开头的 `/` 将模式锚定到包含忽略文件的目录，末尾的 `/` 则匹配目录。

使用 [`moon package --list`](https://docs.moonbitlang.cn/toolchain/moon/commands.html#moon-package) 检查将要打包的文件。

### 已弃用的 `include` 和 `exclude` 字段

警告

`moon.mod` 和 `moon.mod.json` 中的 `include` 与 `exclude` 字段已弃用。新模块和迁移后的模块请使用 `.moonignore`。

现有清单仍可使用其中任一字段。当存在 `include` 时，它是完整的允许列表：不会应用 `exclude`、`.gitignore`、`.moonignore` 以及默认的点前缀路径排除规则。可在 `include` 中使用 `!` 模式为允许列表添加例外。对包根目录 `_build/` 的固定排除仍然有效。

请勿将这些旧字段与忽略文件混用；应将完整的发布策略迁移到 `.moonignore`。

## 首选目标

`preferred_target` 字段允许 `moon` 和语言服务器知道应该使用哪个目标作为默认目标，从而避免在开发针对 Wasm GC 以外的其他后端的项目时需要传递 `--target`。

请在各模块中设置 `preferred_target`。工作区级别的 `preferred-target` 已弃用；`moon run` 使用所选模块自身的首选目标。

moon.mod

```
preferred_target = "js"
```



moon.mod.json

## 支持的目标

`supported_targets` 字段用于声明该模块打算支持哪些后端。与 `preferred_target` 不同，它不会为命令选择默认目标。它的作用是把模块的兼容后端范围记录在元数据中。

`supported_targets` 使用紧凑的目标集合语法：

- `js` 表示单个后端
- `+js+wasm-gc` 表示显式指定一组后端
- `+all-js` 表示除 `js` 之外的所有后端

例如：

moon.mod

```
supported_targets = "+js+wasm-gc"
```



moon.mod.json

为了兼容，旧的数组语法仍然可以使用：

moon.mod

```
supported_targets = ["js", "wasm-gc"]
```



moon.mod.json

`preferred_target` 和 `supported_targets` 经常一起使用：

- `preferred_target` 表示 `moon` 默认应使用哪个后端
- `supported_targets` 表示模块声明自己支持哪些后端

当某个包也定义了 `supported_targets` 时，实际生效的后端集合就是模块级声明与包级声明的交集。

如果你想在包内部按文件做条件编译，应改用 `moon.pkg` / `moon.pkg.json` 中的 [`targets`](https://docs.moonbitlang.cn/toolchain/moon/package.html#conditional-compilation)。

## 源目录

`source` 字段用于指定模块的源目录。

它必须是相对于模块文件所在目录的子目录路径。

当使用 `moon new` 命令创建一个模块时，将自动生成一个 `src` 目录，并且 `source` 字段的默认值将为 `src`。

moon.mod

```
source = "src"
```



moon.mod.json

如果 `source` 字段不存在，或其值为空字符串 `""`，则等同于设置 `source = "."`。这意味着源目录与模块文件所在目录相同。

moon.mod

```
source = ""
```



```
source = "."
```



moon.mod.json

## 警告列表

这用于禁用特定的预设编译器警告编号。

例如，在以下配置中，`-2` 禁用警告编号 2（未使用的变量）。

moon.mod

```
warnings = "-2"
```



moon.mod.json

如果需要禁用多种警告，可以直接连接起来进行组合。

moon.mod

```
warnings = "-2-4"
```



moon.mod.json

如果需要激活某种原来未启用的警告，则使用加号。

moon.mod

```
warnings = "+31"
```



moon.mod.json

你可以使用 `moonc check -warn-help` 查看预设编译器警告编号列表。在下面的输出中，`mnemonic` 是警告列表中使用的符号名称，`id` 是同一警告的数字形式。

```
$ moonc check -warn-help
Available warnings:
mnemonic                   description                                                     id state
unused_value               Unused variable or function.                                     1 warn
unused_value               Unused variable.                                                 2 warn
unused_type_declaration    Unused type declaration.                                         3 warn
missing_priv               Unused abstract type.                                            4 warn
unused_type_variable       Unused type variable.                                            5 warn
unused_constructor         Unused constructor.                                              6 warn
unused_field               Unused field or constructor argument.                            7 warn
redundant_modifier         Redundant modifier.                                              8 warn
struct_never_constructed   Struct never constructed.                                        9 warn
unused_pattern             Unused pattern.                                                 10 warn
partial_match              Partial pattern matching.                                       11 error
unreachable_code           Unreachable code.                                               12 warn
unresolved_type_variable   Unresolved type variable.                                       13 warn
alert or alert_<category>  All alerts or alerts with specific category.                    14 warn
unused_mut                 Unused mutability.                                              15 error
parser_inconsistency       Parser inconsistency check.                                     16 warn
ambiguous_loop_argument    Ambiguous usage of loop argument.                               17 warn
useless_loop               Useless loop expression.                                        18 warn
deprecated                 Deprecated API usage.                                           20 warn
missing_pattern_arguments  Some arguments of constructor are omitted in pattern.           21 warn
ambiguous_block            Ambiguous block.                                                22 warn
unused_try                 Useless try expression.                                         23 warn
unused_error_type          Useless error type.                                             24 warn
test_unqualified_package   Using implicitly imported API in test.                          25 warn
unused_catch_all           Useless catch all.                                              26 warn
deprecated_syntax          Deprecated syntax.                                              27 warn
todo                       Todo                                                            28 warn
unused_package             Unused package.                                                 29 warn
missing_package_alias      Empty package alias.                                            30 warn
unused_optional_argument   Optional argument never supplied.                               31 off
unused_default_value       Default value of optional argument never used.                  32 off
text_segment_excceed       Text segment exceed the line or column limits.                  33 warn
implicit_use_builtin       Implicit use of definitions from `moonbitlang/core/builtin`.    34 warn
reserved_keyword           Reserved keyword.                                               35 warn
block_label_shadowing      Block label shadows another label.                              36 warn
unused_block_label         Unused block label.                                             37 warn
missing_invariant          For-loop is missing an invariant.                               38 off
missing_reasoning          For-loop is missing a proof_reasoning.                          39 off
multiline_string_escape    Deprecated escape sequence in multiline string.                 40 error
missing_rest_mark          Missing `..` in map pattern.                                    41 warn
invalid_attribute          Invalid attribute.                                              42 warn
unused_attribute           Unused attribute.                                               43 warn
invalid_inline_wasm        Invalid inline-wasm.                                            44 error
unused_rest_mark           Useless `..` in pattern                                         46 warn
missing_definition         Unused pub definition because it does not exist in mbti file.   49 warn
method_shadowing           Local method shadows upstream method                            50 warn
ambiguous_precedence       Ambiguous operator precedence                                   51 warn
unused_loop_variable       Loop variable not updated in loop                               52 warn
unused_trait_bound         Unused trait bound                                              53 warn
ambiguous_range_direction  Ambiguous looping direction for range e1..=e2                   54 off
unannotated_ffi            Unannotated FFI param type                                      55 error
missing_pattern_field      Missing field in struct pattern                                 56 warn
missing_pattern_payload    Constructor pattern expect payload                              57 warn
unaligned_byte_access      Unaligned byte access in bits pattern                           59 warn
unused_struct_update       Unused struct update                                            60 warn
duplicate_test             Duplicate test name                                             61 warn
invalid_cascade            Calling method with non-unit return type via `..`               62 warn
syntax_lint                Syntax lint warning                                             63 warn
unannotated_toplevel_array Unannotated toplevel array                                      64 warn
prefer_readonly_array      Suggest ReadOnlyArray for read-only array literal               65 off
prefer_fixed_array         Suggest FixedArray for mutated array literal                    66 off
unused_async               Useless `async` annotation                                      67 warn
declaration_unimplemented  Declaration is unimplemented                                    68 warn
declaration_implemented    Declaration is already implemented                              69 off
deprecated_for_in_method   using `iterator()` method for `for .. in` loop.                 70 off
core_package_not_imported  Packages in `moonbitlang/core` need to be explicitly imported.  71 warn
unqualified_local_using    unqualified local using                                         72 off
unnecessary_annotation     unnecessary type annotation                                     73 off
missing_doc                Missing documentation for public definition                     74 off
unnecessary_view_op        Unnecessary `[:]` view operator                                 75 off
result_error_return        Using `Result[T, E]` where `E` is an error type.                78 off
implicit_impl_as_method    `impl` implicitly promoted as method                            79 warn
regex_match_missing_before Missing `before` binding in `regex match`.                      80 warn
regex_match_missing_after  Missing `after` binding in `regex match`.                       81 warn
ambiguous_braces           Ambiguous `{}` braces.                                          82 warn
type_param_method          Calling method of type parameter in a deprecated way.           83 warn
unqualified_record         Struct literal in a `let` binding without a type prefix.        84 off
unlabelled_break_in_labelled_loop Unlabelled `break` directly inside a labelled loop.             85 warn
unlabelled_continue_in_labelled_loop Unlabelled `continue` directly inside a labelled loop.          86 warn
guard_inexhaustive         `guard` condition is not exhaustive and may panic.              87 warn
guard_redundant_bang       Redundant `!` on an exhaustive `guard`.                         88 warn
guard_redundant_else       Redundant `else` on an exhaustive `guard`.                      89 warn
unused_lexcase             `lexmatch`/`lexscan` branch that can never be selected because other branches takes precedence or its pattern matches nothing.  90 warn
unused_errdefer            unused `errdefer` statement                                     91 warn
fragile_catch_all          fragile `catch` handler that can be converted to `defer` or `errdefer`  92 warn
unknown_constr_pat_on_exhaustive_type using `TypeName::..` pattern on a type not marked with `#non_exhaustive`  93 warn
all                        all warnings
state: warn = enabled, error = promoted to error, off = disabled
note: default alert exceptions: alert_unsafe=off
```



## Rule

模块级 `rule` 条目声明一个可复用的预构建命令，模块内的每个 `moon.pkg` 都可以使用它。模块级 rule 不会自行运行；如果要在构建包之前使用它，需要在 `moon.pkg` 中添加包级 `dev_build` 条目。关于包级配置，请参阅 [Package Configuration](https://docs.moonbitlang.cn/toolchain/moon/package.html#rule-and-dev-build) 中的 "Rule and dev_build" 一节。

使用 `rule(name: "...", command: "...")`，其中 `name` 标识规则，`command` 是一个 shell 命令字符串。该命令可以引用 `$input` 和 `$output`，它们由使用该 rule 的包级 `dev_build` 条目提供。一个模块可以声明多个模块级 `rule` 条目。

moon.mod

```
rule(name: "tool", command: "tool $input -o $output")
```



moon.mod.json

## 脚本

`scripts` 字段用于定义与模块关联的自定义脚本。

### postadd 脚本

`postadd` 脚本在模块添加后自动运行。执行时，脚本的当前工作目录（cwd）设置为模块配置文件所在的目录。

moon.mod

```
options(
  scripts: {
    "postadd": "python3 build.py",
  },
)
```



moon.mod.json

### [实验性] 预构建配置脚本

警告

这个功能是极其实验性的，其 API 可能随时发生变化。本文件反映了截至 2025-06-03 的实现。

重要

使用此功能可能会在您的计算机上执行任意代码。请谨慎使用，仅与受信任的依赖项一起使用。

预构建配置脚本用于辅助 native 目标编程。要使用此类脚本，请将其添加到模块配置中：

moon.mod

```
options(
  "--moonbit-unstable-prebuild": "<path/to/build-script>",
)
```



moon.mod.json

路径是相对于项目根目录的相对路径。脚本可以是 JavaScript 脚本（扩展名为 `.js`、`.cjs`、`.mjs`）使用 `node` 执行，或者是 Python 脚本（扩展名为 `.py`）使用 `python3` 或 `python` 执行。

#### 输入

脚本将从标准输入流（stdin）接收一个具有 `BuildScriptEnvironment` 结构的 JSON：

```
/** 表示构建脚本接收的环境 */
interface BuildScriptEnvironment {
  env: Record<string, string>
  paths: Paths
}

interface BuildInfo {
  /** 当前构建脚本正在运行的目标信息 */
  host: TargetInfo
  /** 正在构建的模块的目标信息 */
  target: TargetInfo
}

interface TargetInfo {
  /** 我们正在使用的实际后端，例如 `wasm32`、`wasmgc`、`js`、`c`、`llvm` */
  kind: string // TargetBackend
}
```



#### 输出

脚本预计将在其标准输出流（stdout）中打印一个具有 `BuildScriptOutput` 结构的 JSON 字符串：

```
interface BuildScriptOutput {
  /** 构建变量 */
  vars?: Record<string, string>
  /** 链接配置 */
  link_configs?: LinkConfig[]
}

interface LinkConfig {
  /** 要配置的包的名称 */
  package: string

  /** 需要传播到依赖项的链接标志
   *
   * 参考：`cargo::rustc-link-arg=FLAG` */
  link_flags?: string

  /** 需要链接的库，传播到依赖项
   *
   * 参考：`cargo::rustc-link-lib=LIB` */
  link_libs?: string[]

  /** 需要在链接期间搜索的路径，传播到依赖项
   *
   * 参考：`cargo::rustc-link-search=[KIND=]PATH` */
  link_search_paths?: string[]
}
```



#### 构建变量

您可以在 `moon.pkg` 的本地链接参数中使用 `vars` 字段中发出的变量，格式为 `${build.<var_name>}`。

例如，如果您的构建脚本输出：

```
{ "vars": { "CC": "gcc" } }
```



并且您的 `moon.pkg` 结构如下：

moon.pkg

```
options(
  link: { "native": { "cc": "${build.CC}" } },
)
```



它会被转换为

```
{
  "link": {
    "native": {
      "cc": "gcc"
    }
  }
}
```

# 包配置

moon 使用包配置文件来标识和描述一个包。旧格式是 `moon.pkg.json`，新格式是 `moon.pkg`。访问 [moon 的仓库](https://github.com/moonbitlang/moon/blob/main/crates/moonbuild/template/pkg.schema.json) 查看完整的 JSON 模式。

常规工具链命令不再接受 `moon.pkg.json`。请先使用 `moon fmt` 迁移现有 JSON 配置文件，再进行检查或构建。下方的 JSON 示例仅供迁移参考，不应作为新项目的配置。

## 新格式（`moon.pkg`）

新格式是简洁的 DSL。你可以通过以下命令从现有 `moon.pkg.json` 生成或重新格式化：

```
moon -C <module_dir> fmt
```



示例：

```
import {
  "moonbit-community/language/packages/virtual",
}

pkgtype(kind: "executable")

options(
  overrides: [ "moonbit-community/language/packages/implement" ],
)
```



在 `moon.pkg` 中，依赖通过 `import { ... }` 块声明。使用 `@alias` 设置自定义别名：

```
import {
  "moonbit-community/language/packages/pkgA",
  "moonbit-community/language/packages/pkgC" @c,
  "moonbitlang/core/builtin",
}
```



简单的包设置可以直接书写，名称使用下划线分隔，例如 `proof_enabled = true` 或 `regex_backend = "table"`。`formatter`、`pkgtype` 和 `virtual` 等声明有专用的顶层形式。`moon fmt` 会将 `options(...)` 中支持的设置迁移为这些形式。仍保留在 `options` 中且包含 `-` 的旧键名必须加引号。

```
virtual(has_default: true)
```



`moon.pkg` 格式支持 `//...` 注释。

`moon.pkg` 的完整语法定义如下：

```
moon_pkg ::= statement*
statement ::= import | assign | apply

import ::= "import" "{" (import_item ",")* import_item? "}" import_kind?
import_item ::= STRING ("@" PKG_NAME)?
import_kind ::= "for" STRING

assign ::= LIDENT "=" expr

apply ::= LIDENT "(" (argument ",")* argument? ")"
argument ::= LIDENT ":" expr | STRING ":" expr  

expr ::= array | object | apply | STRING | INT | "true" | "false"
array ::= "[" (expr ",")* expr? "]"
object ::= "{" (field ",")* field? "}"
```



## 名称

包名称不可配置；它由包的文件夹目录名称确定。

## 格式化

`formatter` 字段用于为此包配置 `moon fmt`。目前它支持 `ignore`，即格式化器应跳过的文件名列表。

这对于生成文件或你有意保持为不同格式的文件很有用。由 `pre-build` 生成的文件已经会被自动跳过，因此 `formatter.ignore` 主要用于额外排除你想忽略的文件。

moon.pkg

```
formatter(ignore: ["generated.mbt", "snapshot.mbt"])
```



moon.pkg.json

## 包类型

使用一条 `pkgtype` 声明指定包的构建类型。例如，可执行包使用：

```
pkgtype(kind: "executable")
```



可用的类型包括 `library`、`executable` 和 `foreign_library`。默认值是 `library`。`executable` 取代旧的 `options("is-main": true)`，`foreign_library` 取代旧的 `options(link: true)`。这些类型互为替代项，不能同时声明。

在外部库包中，`#export_name` 为公开的非泛型函数指定其在生成的 Wasm、JavaScript 或 C 输出中的稳定符号名称：

```
#export_name("attr_add")
pub fn add_by_attr(n : Int32) -> Int32 {
  n + 42
}
```



MoonBit 目前要求导出名是有效的 C 符号标识符且在包内唯一，无论选择哪个后端都是如此。

警告

已知编译器问题：`#export_name` 目前会对所有后端施加 C 符号标识符限制。WebAssembly 导出名是 UTF-8 字符串，并不限于 C 标识符。

该属性不能用于泛型函数或带可选参数的函数。对于新的导出，优先使用 `#export_name`，而不是各后端的 `exports` 链接配置。

导出声明的作用域是生成产物的包。依赖中的属性或 `exports` 配置在该依赖自身构建为产物时生效，但不会向下游包的产物添加符号。若要暴露依赖的功能，请在执行导出的包中定义并导出一个包装函数。

备注

native 后端目前不支持将 `foreign_library` 包导出为可链接的库产物，包括 `.dll` 或 `.so` 等共享库。



## is-main（已弃用）

`is-main` 字段已弃用。为了兼容现有包配置，它仍可使用；但新建或迁移后的 `moon.pkg` 应改用 `pkgtype(kind: "executable")`。以下旧声明与该 `pkgtype` 声明等价：

链接过程的输出取决于后端。当此字段设置为 `true` 时：

- 对于 Wasm 和 `wasm-gc` 后端，将生成一个独立的 WebAssembly 模块。
- 对于 `js` 后端，将生成一个独立的 JavaScript 文件。

moon.pkg

```
options(
  "is-main": true,
)
```



moon.pkg.json

## 导入依赖

### 导入

`import` 字段用于指定包依赖的其他包。

例如，以下导入 `pkgA` 和 `pkgC`，将 `pkgC` 别名为 `c`。 用户可以使用 `@c` 访问 `pkgC` 中的定义。

moon.pkg

```
import {
  "moonbit-community/language/packages/pkgA",
  "moonbit-community/language/packages/pkgC" @c,
  "moonbitlang/core/builtin",
}
```



moon.pkg.json

大多数 core 包在这里仍按普通包处理：如果你使用 `@json`、`@test` 或其他普通的 core 别名，请将对应的 `moonbitlang/core/...` 包加入 `import`，以避免 `core_package_not_imported` 警告。

`prelude` 是例外。它默认可用，因此它暴露的名称不需要显式导入对应的包。

### 测试导入

测试导入于指定此包的黑盒测试包依赖的其他包，配置语法与 `import` 相同

moon.pkg

```
import {
  "path/to/package1",
  "path/to/package2" @pkg2,
} for "test"
```



moon.pkg.json

`test-import-all` 字段用于指定是否导入被测试包的公共定义（默认为 `true`）。

### 白盒测试导入

白盒测试导入用于指定此包的白盒测试包依赖的其他包，配置语法与 `import` 相同。

moon.pkg

```
import {
  "path/to/package1",
  "path/to/package2" @pkg2,
} for "wbtest"
```



moon.pkg.json

## 最大并发测试数

`max-concurrent-tests` 字段用于限制在 `moon test` 执行该包时，此包的测试同时运行的最大数量。

当同一包中的测试共享端口、临时文件或其他不应全部并行运行的外部资源时，这很有用。

moon.pkg

```
options(
  "max-concurrent-tests": 2,
)
```



moon.pkg.json

## 条件编译

条件编译的最小单元是一个文件。

在条件编译表达式中，支持三种逻辑运算符：`and`、`or` 和 `not`，其中 `or` 运算符可以省略。

例如，`["or", "wasm", "wasm-gc"]` 可以简化为 `["wasm", "wasm-gc"]`。

表达式中的条件可以被归类为后端和优化层次：

- **后端条件**：`"wasm"`、`"wasm-gc"` 和 `"js"`
- **优化层次条件**：`"debug"` 和 `"release"`

条件表达式支持嵌套。

如果文件未列在 `"targets"` 中，它将默认在所有条件下编译。

示例：

moon.pkg

```
options(
  targets: {
    "only_js.mbt": ["js"],
    "only_wasm.mbt": ["wasm"],
    "only_wasm_gc.mbt": ["wasm-gc"],
    "all_wasm.mbt": ["wasm", "wasm-gc"],
    "not_js.mbt": ["not", "js"],
    "only_debug.mbt": ["debug"],
    "js_and_release.mbt": ["and", ["js"], ["release"]],
    "js_only_test.mbt": ["js"],
    "js_or_wasm.mbt": ["js", "wasm"],
    "wasm_release_or_js_debug.mbt": ["or", ["and", "wasm", "release"], ["and", "js", "debug"]]
  }
)
```



moon.pkg.json

## 支持的目标

`supported_targets` 字段用于声明一个包打算支持哪些后端。它使用的是目标集合表达式，而不是数组：

moon.pkg

```
supported_targets = "js"
```



moon.pkg.json

示例：

- `js` 表示单个后端
- `+js+wasm-gc` 表示显式指定一组后端
- `+all-js` 表示除 `js` 之外的所有后端

为了兼容，旧的数组语法仍然可以使用：

moon.pkg

```
supported_targets = ["js", "native"]
```



moon.pkg.json

这是包级元数据，不是条件编译规则：

- 使用 `supported_targets` 声明该包支持的后端集合
- 使用 `targets` 为不同后端包含或排除单独的文件
- 在 `moon.mod` 中使用 `preferred_target` 为 `moon check`、`moon run`、`moon build` 等命令选择默认后端

当模块和包都声明了 `supported_targets` 时，实际生效的后端集合就是它们的交集。

命令行为取决于所选择的后端：

- `moon check`、`moon build`、`moon test` 和 `moon bench` 只保留支持所选后端的包
- `moon run` 要求被选中的包支持所选后端
- `moon info` 会跳过不支持的选中包，并给出警告
- `moon bundle` 会跳过不支持所选后端的包目标

在根包选择完成后，Moon 还会检查可达的必需依赖。如果某个必需依赖不支持所选后端，命令会以正常的面向用户的错误信息失败。

注意：

- 省略 `supported_targets` 表示支持所有后端
- `--target all` 会展开为 `wasm`、`wasm-gc`、`js` 和 `native`，但不包括 `llvm`
- `llvm` 仍然是合法的 `supported_targets` 值
- 旧的数组语法已被弃用，但为了兼容仍然接受

一种常见的配置方式是：

- 用 `supported_targets = "native"` 标记仅支持 native 的包
- 在 `moon.mod` 中设置 `preferred_target = "native"`
- 只有当包内某些文件因后端不同而变化时，才使用 `targets`

## 原生存根文件

`native-stub` 字段列出应在 native 构建中与此包一起编译的 C 存根源文件。

这通常与 [FFI 文档中的 `extern "C"` 声明](https://docs.moonbitlang.cn/language/ffi.html) 一起使用，此时存根文件提供用 C 编写比直接用 MoonBit 编写更容易的包装函数或适配代码。

路径相对于包目录。

moon.pkg

```
options(
  "native-stub": [ "stub.c", "helpers.c" ],
)
```



moon.pkg.json

## 链接选项

声明为 `executable` 或 `foreign_library` 的包会生成链接后的输出。布尔形式的 `link: true` 是旧写法；包需要为外部代码构建库时，请使用 `pkgtype(kind: "foreign_library")`。对象形式的 `link` 选项用于配置特定后端的链接行为。

`link` 选项用于指定链接选项，其值可以是布尔值或对象。

目前，`link` 对 native 后端不起作用。本节描述的行为适用于 `wasm`、`wasm-gc` 和 `js` 后端。

对于新的函数导出，优先使用 [`#export_name`](https://docs.moonbitlang.cn/language/attributes.html#export-name-attribute)。当导出集合或名称需要因后端而异，或者无法修改源代码添加属性时，使用各后端的 `exports` 字段。

- 当 `link` 值为 `true` 时，表示应链接包。输出将根据构建时指定的后端而有所不同。

  moon.pkg

  ```
  options(
    link: true
  )
  ```

  

  moon.pkg.json

- 当 `link` 值为对象时，表示应链接包，您可以指定链接选项。有关详细配置，请参阅相应后端的子页面。

### Wasm 后端链接选项

#### 共有选项

- `exports` 选项用于指定 Wasm 后端导出的函数名称。

  例如，在以下配置中，当前包中的 `hello` 函数被导出为 `wasm` 模块中的 `hello` 函数，`foo` 函数被导出为 Wasm 模块中的 `bar` 函数。在 Wasm 宿主中，可以调用 `hello` 和 `bar` 函数来调用当前包中的 `hello` 和 `foo` 函数。

  moon.pkg

  ```
  options(
    link: {
      "wasm": {
        "exports": [ "hello", "foo:bar" ],
      },
      "wasm-gc": {
        "exports": [ "hello", "foo:bar" ],
      }
    }
  )
  ```

  

  moon.pkg.json

- `import-memory` 选项用于指定 Wasm 模块导入的线性内存。

  例如，以下配置指定 Wasm 模块导入的线性内存是 `env` 模块的 `memory` 变量。

  moon.pkg

  ```
  options(
    link: {
      "wasm": {
        "import-memory": {
          "module": "env",
          "name": "memory",
        },
      },
      "wasm-gc": {
        "import-memory": {
          "module": "env",
          "name": "memory",
        },
      },
    },
  )
  ```

  

  moon.pkg.json

- `memory-limits` 选项用于指定 Wasm 模块所使用线性内存的最小和最大大小。

- `shared-memory` 选项用于启用共享线性内存。

  例如，以下配置为 `wasm` 和 `wasm-gc` 后端同时设置了内存限制并启用了共享内存。

  moon.pkg

  ```
  options(
    link: {
      "wasm": {
        "memory-limits": {
          "min": 1,
          "max": 65536,
        },
        "shared-memory": true,
      },
      "wasm-gc": {
        "memory-limits": {
          "min": 1,
          "max": 65535,
        },
        "shared-memory": true,
      },
    },
  )
  ```

  

  moon.pkg.json

- `export-memory-name` 选项用于指定 Wasm 模块导出的线性内存的名称。

  moon.pkg

  ```
  options(
    link: {
      "wasm": {
        "export-memory-name": "memory",
      },
      "wasm-gc": {
        "export-memory-name": "memory",
      },
    },
  )
  ```

  

  moon.pkg.json

#### Wasm 线性内存后端链接选项

- `heap-start-address` 选项用于指定编译到 Wasm 后端时可以使用的线性内存的起始地址。

  例如，以下配置将线性内存的起始地址设置为 1024。

  moon.pkg

  ```
  options(
    link: {
      "wasm": {
        "heap-start-address": 1024,
      },
    },
  )
  ```

  

  moon.pkg.json

#### Wasm GC 后端链接选项

- `use-js-builtin-string` 选项用于指定在编译到 Wasm GC 后端时是否应启用 [内建 JS String 提案](https://github.com/WebAssembly/js-string-builtins/blob/main/proposals/js-string-builtins/Overview.md)。它将使 MoonBit 中的 `String` 等效于 JavaScript 宿主运行时中的 `String`。

  例如，以下配置将启用内建 JS String 提案。

  moon.pkg

  ```
  options(
    link: {
      "wasm-gc": {
        "use-js-builtin-string": true,
      },
    },
  )
  ```

  

  moon.pkg.json

- `imported-string-constants` 选项用于指定内建 JS String 提案使用的导入字符串命名空间，默认为 `_`。它应符合 JS 宿主运行时中的配置。

  例如，以下配置与 JS 初始化配置了导入字符串命名空间。

  moon.pkg

  ```
  options(
    link: {
      "wasm-gc": {
        "use-js-builtin-string": true,
        "imported-string-constants": "_",
      },
    },
  )
  ```

  

  moon.pkg.json

  ```
  const { instance } = await WebAssembly.instantiate(bytes, {}, { importedStringConstants: "strings" });
  ```

  

### JS 后端链接选项

- `exports` 选项用于指定要在 JavaScript 模块中导出的函数名称。

  例如，在以下配置中，当前包中的 `hello` 函数被导出为 JavaScript 模块中的 `hello` 函数。在 JavaScript 宿主中，可以调用 `hello` 函数来调用当前包中的 `hello` 函数。

  moon.pkg

  ```
  options(
    link: {
      "js": {
        "exports": [ "hello" ],
      },
    },
  )
  ```

  

  moon.pkg.json

- `format` 选项用于指定 JavaScript 模块的输出格式。

  目前支持的格式有：

  - `esm`（默认）
  - `cjs`
  - `iife`

  例如，以下配置将当前包的输出格式设置为 ES 模块。

  moon.pkg

  ```
  options(
    link: {
      "js": {
        "format": "esm",
      },
    },
  )
  ```

  

  moon.pkg.json

### 原生后端链接选项

- `cc` 选项用于指定用于编译 `moonc` 生成的 C 源文件的编译器。它可以是编译器的完整路径，也可以是通过 PATH 环境变量可访问的简单名称。

  moon.pkg

  ```
  options(
    link: {
      "native": {
        "cc": "/usr/bin/gcc13",
      },
    },
  )
  ```

  

  moon.pkg.json

- `cc-flags` 选项用于覆盖传递给编译器的默认标志。例如，您可以使用以下标志来定义一个名为 MOONBIT 的宏。

  moon.pkg

  ```
  options(
    link: {
      "native": {
        "cc-flags": "-DMOONBIT",
      },
    },
  )
  ```

  

  moon.pkg.json

- `cc-link-flags` 选项用于覆盖传递给链接器的默认标志。由于链接器是通过编译器驱动程序调用的（例如，通过 `cc` 而不是 `ld`，通过 `cl` 而不是 `link`），因此在传递特定选项时，应该使用 `-Wl,` 或 `/link `前缀。

  以下示例从生成的二进制文件中剥离符号信息。

  moon.pkg

  ```
  options(
    link: {
      "native": {
        "cc-link-flags": "-s",
      },
    },
  )
  ```

  

  moon.pkg.json

- `stub-cc` 选项与 `cc` 类似，但控制用于编译存根的编译器。虽然它可以与 `cc` 不同，但不建议这样做，应仅用于调试目的。因此，我们强烈建议同时指定 `cc` 和 `stub-cc` 并使它们保持一致，以避免潜在冲突。

- `stub-cc-flags` 选项类似于 `cc-flags`。它仅对存根编译有效。

- `stub-cc-link-flags` 与 `cc-link-flags` 类似，但有微妙的区别。通常，存根被编译为目标文件，并与从 `moonc` 生成的 C 源文件的目标文件链接。这种链接仅由前面提到的 `cc-flags` 和 `cc-link-flags` 控制。然而，在特定模式下，存根目标文件将有一个单独的链接过程，在该过程中，`stub-cc-link-flags` 将生效。

#### 原生后端的默认 C 编译器和编译器标志

以下是对 [compiler_flags.rs](https://github.com/moonbitlang/moon/blob/main/crates/moonutil/src/compiler_flags.rs) 的简要总结。

##### C 编译器

在 Windows 上，native 后端需要带有 C++ 工具和 Windows SDK 的 MSVC 兼容工具链。支持 Microsoft `cl.exe` 和 LLVM `clang-cl.exe`。不支持 MinGW 工具链。

在其他平台上，Moon 会按以下顺序在 PATH 中查找：

- gcc
- clang
- cc

对于类似 GCC 的编译器，默认的编译和链接命令如下。`[]` 用于指示某些模式下可能不存在的标志。

```
cc -o $target -I$MOON_HOME/include -L$MOON_HOME/lib [-g] [-shared -fPIC] \
   -fwrapv -fno-strict-aliasing (-O2|-Og) [$MOON_HOME/lib/libmoonbitrun.o] \
   $sources -lm $cc_flags $cc_link_flags
```



对于 Windows 上兼容 MSVC 的编译器驱动，默认的编译和链接命令如下。

```
cl (/Fo|/Fe)$target -I$MOON_HOME/include [/LD] /utf-8 /wd4819 /nologo (/O2|/Od) \
   /link /LIBPATH:$MOON_HOME/lib
```



## Rule 和 dev_build

`rule` 声明一个可复用的命令，`dev_build` 将一条 rule 应用于具体的输入和输出文件。这些预构建步骤会在 `moon check`、`moon build` 和 `moon test` 等开发命令之前运行。

此机制面向包作者在包开发期间使用。当该包作为依赖被下游用户使用时，出于安全原因，这些预构建步骤不会被触发，因此依赖不会在构建期间执行任意命令。请将生成的输出文件提交到仓库，使下游用户可以直接基于这些文件构建。

`rule(name: "...", command: "...")` 声明一个可复用的命令模板。`name` 字段标识该 rule，`command` 是一个 shell 命令字符串。命令可以引用 `$input` 和 `$output`，它们由使用该 rule 的 `dev_build` 条目提供。一个包可以声明多个 `rule` 条目。

`dev_build(rule: "...", input: "...", output: "...")` 声明一个预构建步骤。它选择一条 rule，并提供展开该 rule 命令时使用的输入和输出路径。一个包可以声明多个 `dev_build` 条目。

预构建命令以模块根目录作为工作目录。输入、输出和其他预构建路径都相对于模块根目录解析。

可以在同一个 `moon.pkg` 中声明包级 rule，也可以在 [`moon.mod`](https://docs.moonbitlang.cn/toolchain/moon/module.html) 中声明模块级 rule。包级 rule 只对同一个 `moon.pkg` 中的 `dev_build` 条目可见；模块级 rule 对模块内每个包中的 `dev_build` 条目可见。解析 rule 名称时，`moon` 会先在同一个 `moon.pkg` 中查找包级 rule，再在 `moon.mod` 中查找模块级 rule。

moon.pkg

```
rule(name: "copy", command: "cat $input > $output")
dev_build(rule: "copy", input: "a.txt", output: "a.mbt")
```



moon.pkg.json

在此示例中，运行 `moon check` 等开发命令时，会在检查包之前将 `a.txt` 的内容复制到 `a.mbt`。

## 警告列表

警告列表用于禁用或启用警告。若要让已启用的警告导致命令失败，请使用 `--deny-warn`。警告列表是由一个或多个警告名称组成的字符串，每个名称前都有一个符号前缀：

- `-`用于关闭警告
- `+`用于启用警告

例如，在以下配置中，`-unused_value` 禁用函数或者变量未使用警告。

moon.pkg

```
warnings = "-unused_value"
```



moon.pkg.json

如果需要禁用多种警告，可以直接连接起来进行组合。

moon.pkg

```
warnings = "-unused_value-unreachable_code"
```



moon.pkg.json

如果需要激活某种原来未启用的警告，则使用加号。

moon.pkg

```
warnings = "+unused_optional_argument"
```



moon.pkg.json

旧配置可能使用 `@` 前缀将警告提升为错误。该前缀仅为兼容性而保留，新配置不应再使用。需要让警告导致构建失败时，请使用 `moon check --deny-warn`（其他 CI 命令使用对应的选项）。

也可以在 `warnings` 中使用警告编号。在以下输出中，`mnemonic` 是警告列表使用的符号名称，`id` 是同一警告的数字形式。

`moonc check -warn-help` 当前输出的列表如下：

```
Available warnings:
mnemonic                   description                                                     id state
unused_value               Unused variable or function.                                     1 warn
unused_value               Unused variable.                                                 2 warn
unused_type_declaration    Unused type declaration.                                         3 warn
missing_priv               Unused abstract type.                                            4 warn
unused_type_variable       Unused type variable.                                            5 warn
unused_constructor         Unused constructor.                                              6 warn
unused_field               Unused field or constructor argument.                            7 warn
redundant_modifier         Redundant modifier.                                              8 warn
struct_never_constructed   Struct never constructed.                                        9 warn
unused_pattern             Unused pattern.                                                 10 warn
partial_match              Partial pattern matching.                                       11 error
unreachable_code           Unreachable code.                                               12 warn
unresolved_type_variable   Unresolved type variable.                                       13 warn
alert or alert_<category>  All alerts or alerts with specific category.                    14 warn
unused_mut                 Unused mutability.                                              15 error
parser_inconsistency       Parser inconsistency check.                                     16 warn
ambiguous_loop_argument    Ambiguous usage of loop argument.                               17 warn
useless_loop               Useless loop expression.                                        18 warn
deprecated                 Deprecated API usage.                                           20 warn
missing_pattern_arguments  Some arguments of constructor are omitted in pattern.           21 warn
ambiguous_block            Ambiguous block.                                                22 warn
unused_try                 Useless try expression.                                         23 warn
unused_error_type          Useless error type.                                             24 warn
test_unqualified_package   Using implicitly imported API in test.                          25 warn
unused_catch_all           Useless catch all.                                              26 warn
deprecated_syntax          Deprecated syntax.                                              27 warn
todo                       Todo                                                            28 warn
unused_package             Unused package.                                                 29 warn
missing_package_alias      Empty package alias.                                            30 warn
unused_optional_argument   Optional argument never supplied.                               31 off
unused_default_value       Default value of optional argument never used.                  32 off
text_segment_excceed       Text segment exceed the line or column limits.                  33 warn
implicit_use_builtin       Implicit use of definitions from `moonbitlang/core/builtin`.    34 warn
reserved_keyword           Reserved keyword.                                               35 warn
block_label_shadowing      Block label shadows another label.                              36 warn
unused_block_label         Unused block label.                                             37 warn
missing_invariant          For-loop is missing an invariant.                               38 off
missing_reasoning          For-loop is missing a proof_reasoning.                          39 off
multiline_string_escape    Deprecated escape sequence in multiline string.                 40 error
missing_rest_mark          Missing `..` in map pattern.                                    41 warn
invalid_attribute          Invalid attribute.                                              42 warn
unused_attribute           Unused attribute.                                               43 warn
invalid_inline_wasm        Invalid inline-wasm.                                            44 error
unused_rest_mark           Useless `..` in pattern                                         46 warn
missing_definition         Unused pub definition because it does not exist in mbti file.   49 warn
method_shadowing           Local method shadows upstream method                            50 warn
ambiguous_precedence       Ambiguous operator precedence                                   51 warn
unused_loop_variable       Loop variable not updated in loop                               52 warn
unused_trait_bound         Unused trait bound                                              53 warn
ambiguous_range_direction  Ambiguous looping direction for range e1..=e2                   54 off
unannotated_ffi            Unannotated FFI param type                                      55 error
missing_pattern_field      Missing field in struct pattern                                 56 warn
missing_pattern_payload    Constructor pattern expect payload                              57 warn
unaligned_byte_access      Unaligned byte access in bits pattern                           59 warn
unused_struct_update       Unused struct update                                            60 warn
duplicate_test             Duplicate test name                                             61 warn
invalid_cascade            Calling method with non-unit return type via `..`               62 warn
syntax_lint                Syntax lint warning                                             63 warn
unannotated_toplevel_array Unannotated toplevel array                                      64 warn
prefer_readonly_array      Suggest ReadOnlyArray for read-only array literal               65 off
prefer_fixed_array         Suggest FixedArray for mutated array literal                    66 off
unused_async               Useless `async` annotation                                      67 warn
declaration_unimplemented  Declaration is unimplemented                                    68 warn
declaration_implemented    Declaration is already implemented                              69 off
deprecated_for_in_method   using `iterator()` method for `for .. in` loop.                 70 off
core_package_not_imported  Packages in `moonbitlang/core` need to be explicitly imported.  71 warn
unqualified_local_using    unqualified local using                                         72 off
unnecessary_annotation     unnecessary type annotation                                     73 off
missing_doc                Missing documentation for public definition                     74 off
unnecessary_view_op        Unnecessary `[:]` view operator                                 75 off
result_error_return        Using `Result[T, E]` where `E` is an error type.                78 off
implicit_impl_as_method    `impl` implicitly promoted as method                            79 warn
regex_match_missing_before Missing `before` binding in `regex match`.                      80 warn
regex_match_missing_after  Missing `after` binding in `regex match`.                       81 warn
ambiguous_braces           Ambiguous `{}` braces.                                          82 warn
type_param_method          Calling method of type parameter in a deprecated way.           83 warn
unqualified_record         Struct literal in a `let` binding without a type prefix.        84 off
unlabelled_break_in_labelled_loop Unlabelled `break` directly inside a labelled loop.             85 warn
unlabelled_continue_in_labelled_loop Unlabelled `continue` directly inside a labelled loop.          86 warn
guard_inexhaustive         `guard` condition is not exhaustive and may panic.              87 warn
guard_redundant_bang       Redundant `!` on an exhaustive `guard`.                         88 warn
guard_redundant_else       Redundant `else` on an exhaustive `guard`.                      89 warn
unused_lexcase             `lexmatch`/`lexscan` branch that can never be selected because other branches takes precedence or its pattern matches nothing.  90 warn
unused_errdefer            unused `errdefer` statement                                     91 warn
fragile_catch_all          fragile `catch` handler that can be converted to `defer` or `errdefer`  92 warn
unknown_constr_pat_on_exhaustive_type using `TypeName::..` pattern on a type not marked with `#non_exhaustive`  93 warn
all                        all warnings
state: warn = enabled, error = promoted to error, off = disabled
note: default alert exceptions: alert_unsafe=off
```



备注

使用 `moonc check -warn-help` 查看预设编译器警告列表。

### `alert`警告

`alert`是一种特殊的警告，表示使用了某些被 [`#internal`属性](https://docs.moonbitlang.cn/language/attributes.html#internal-attribute) 标记了的 API。

所有`alert`都附有一个类别，这是由 API 的作者定义的。你可以通过`alert_<类别>`这样的警告名来启用或者关闭特定的`alert`类别，或者用`alert`一次性控制所有`alert`警告。

例如，以下配置启用除 `unsafe` 类别以外的所有 alert 警告。在 CI 中，请为 `moon check`、`moon test` 或相应命令添加 `--deny-warn`，将已启用的警告视为致命错误。

moon.pkg

```
warnings = "+alert-alert_unsafe"
```



moon.pkg.json

## 虚拟包

一个虚拟包可以作为一个包的接口被实际的实现替换。

### 声明

`virtual` 字段用于将当前包声明为虚拟包。

例如，以下配置声明了一个具有默认实现的虚拟包：

moon.pkg

```
virtual(has_default: true)
```



moon.pkg.json

### 实现

使用 `virtual(implement: "package/path")` 声明当前包所实现的虚包。

例如，以下配置实现了一个虚拟包：

moon.pkg

```
virtual(implement: "moonbitlang/core/abort")
```



moon.pkg.json

### 覆盖实现

`overrides` 字段用于提供满足导入虚拟包的实现。

例如，以下配置将内置的 abort 包的默认实现替换为另一个包：

moon.pkg

```
options(
  overrides: [ "moonbitlang/dummy_abort/abort_show_msg" 
)
moon.pkg.json
"overrides": ["moonbitlang/dummy_abort/abort_show_msg"]
```

# 测量代码覆盖率

我们为您提供了工具，用于测量测试和程序运行的代码覆盖率。目前的测量基于分支覆盖率。换句话说，它测量了每个程序分支是否被执行，以及如果执行了多少次。

## 在测试中运行代码覆盖率

要在测试中启用覆盖率仪器，您需要将 `--enable-coverage` 参数传递给 `moon test`。

```
$ moon test --enable-coverage
...
Total tests: 3077, passed: 3077, failed: 0.
```



如果之前没有使用覆盖率启用编译项目，这将重新编译项目。执行过程看起来是一样的，但是新的覆盖率结果文件将在 `target` 目录下生成。

```
$ ls _build/wasm-gc/debug/test/ -w1
array
...
moonbit_coverage_1735628238436873.txt
moonbit_coverage_1735628238436883.txt
...
moonbit_coverage_1735628238514678.txt
option/
...
```



这些文件包含了工具链用于确定程序的哪些部分被执行，哪些部分没有被执行的信息。

## 可视化覆盖率结果

要可视化覆盖率仪器的结果，您需要使用 `moon coverage report` 子命令。

子命令可以以多种格式导出覆盖率，由 `-f` 标志控制：

- 文字摘要：`summary`
- OCaml Bisect 格式：`bisect`（默认）
- Coveralls JSON 格式：`coveralls`
- Coberura XML 格式：`cobertura`
- HTML 页面：`html`

### 文字摘要

`moon coverage report -f summary` 将覆盖率数据导出到 stdout，打印每个文件的覆盖点和总覆盖点计数。

```
$ moon coverage report -f summary
array/array.mbt: 21/22
array/array_nonjs.mbt: 3/3
array/blit.mbt: 3/3
array/deprecated.mbt: 0/0
array/fixedarray.mbt: 115/115
array/fixedarray_sort.mbt: 110/116
array/fixedarray_sort_by.mbt: 58/61
array/slice.mbt: 6/6
array/sort.mbt: 70/70
array/sort_by.mbt: 56/61
...
```



### OCaml Bisect 格式

这是未指定 `-f` 时的默认导出格式。

`moon coverage report -f bisect` 将覆盖率数据导出到一个文件 `bisect.coverage`，可以被 [OCaml Bisect][bisect] 工具读取。

### Coveralls JSON 格式

`moon coverage report -f coveralls` 将覆盖率数据导出到 Coveralls 的 JSON 格式。这种格式是基于行的，可以被 Coveralls 和 CodeCov 读取。您可以在 [这里](https://docs.coveralls.io/api-introduction#json-format-web-data) 找到其规范。

```
$ moon coverage report -f coveralls
$ cat coveralls.json
{
    "source_files": [
        {
            "name": "builtin/console.mbt",
            "source_digest": "1c24532e12ac5bdf34b7618c9f38bd82",
            "coverage": [null,null,...,null,null]
        },
        {
            "name": "immut/array/array.mbt",
            "source_digest": "bcf1fb1d2f143ebf4423565d5a57e84f",
            "coverage": [null,null,null,...
```



您可以使用 `--send-to` 参数直接将此覆盖率报告发送到 Coveralls 或 CodeCov。以下是在 GitHub Actions 中使用它的示例：

```
moon coverage report \
    -f coveralls \
    -o codecov_report.json \
    --service-name github \
    --service-job-id "$GITHUB_RUN_NUMBER" \
    --service-pull-request "${{ github.event.number }}" \
    --send-to coveralls

env:
    COVERALLS_REPO_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```



更多信息可以在 `moon coverage report --help` 中找到。

### Cobertura XML 格式

`moon coverage report -f cobertura` 将覆盖率数据导出到可以被 [Cobertura](https://cobertura.github.io/cobertura/) 读取的格式。

### HTML

`moon coverage report -f html` 将覆盖率数据导出到一系列易于阅读的 HTML 文件中。默认的导出位置是名为 `_coverage` 的文件夹。

文件夹中的 `index.html` 显示了所有源文件的列表，以及其中的覆盖率百分比：

![HTML 的索引](https://docs.moonbitlang.cn/_images/coverage_html_index.png)

单击每个文件会显示每个文件中的覆盖率详细信息。每个覆盖点（分支的开始）在源代码中由一个突出显示的字符表示：红色表示该点在所有运行中都没有被执行，绿色表示该点至少被执行一次。

每行也通过覆盖率信息进行突出显示，具有相同的颜色编码。此外，黄色行是那些具有部分覆盖率的行：该行中的某些点被执行，而其他点没有被执行。

有些行不会有任何突出显示。这并不意味着该行根本没有被执行，只是该行不是分支的开始。这样的行共享其前面最近被执行的行的覆盖率。

![详细覆盖率数据](https://docs.moonbitlang.cn/_images/coverage_html_page.png)

## 跳过覆盖检查

添加 `#coverage.skip` 属性会跳过函数内的所有覆盖操作。此外，所有已弃用的函数都不会被覆盖检查。

# MoonBit Agent IDE

## 概览

`moon ide` 是一套专门用于导航、理解和探索 MoonBit 代码库的 CLI 工具。它基于编译器对项目结构的理解，提供具备语义感知能力的代码发现工具。

这些命令使用语义分析而不是文本匹配，因此在代码导航任务中比基于 grep 的搜索更精确。

导航命令适用于模块、多模块工作区以及独立的 `.mbtx` 脚本。在多模块工作区中，`moon ide` 遵循各模块所配置的后端。对于单个模块，提供 `--target` 选项的命令可以选择项目检查所使用的后端。

### 可用命令

- **`moon ide peek-def`**：在上下文中定位符号定义
- **`moon ide find-references`**：定位符号在整个项目中的所有用法
- **`moon ide rename`**：计算或应用语义重命名编辑
- **`moon ide hover`**：显示源码位置处的类型和文档
- **`moon ide outline`**：获取文件或包的结构概览
- **`moon ide analyze`**：报告公共 API 的使用次数
- **`moon ide doc`**：结合文档发现并探索 API
- **`moon ide workspace-symbols`**：搜索工作区的顶层符号
- **`moon ide codelens`**：以 JSON 返回引用 CodeLens 条目
- **`moon ide gen-symbols`**：生成包符号索引

## 符号语法

接受 `<symbol>` 参数的命令使用以下模式：

**基础符号：**

- `[@pkg.]symbol` - 包中的符号（例如 `parse_int`、`Array`）
- 如果省略 `@pkg.`，则搜索当前包和 prelude

**类型成员：**

- `[@pkg.]Type::member` - 类型方法、结构体字段、枚举变体、trait 方法
- `Trait::method for Type` - 某个类型对 trait 方法的实现
- 示例：`Array::length`、`@http.Request::new`、`Option::None`

对于当前包和标准库中的符号，包前缀 `@pkg.` 是可选的。

## `moon ide peek-def` - 查看符号定义

快速定位符号定义及其周边上下文。相比用 grep 查找声明，这种方式更快也更准确。

### 用法

```
moon ide peek-def <symbol> [--loc filename[:line[:col]]]
```



**查找模式：**

1. **全局搜索**（不带 `--loc`）：使用上文描述的符号语法搜索模块或工作区。
2. **限定文件的搜索**（`--loc filename`）：将初次符号查找限定在一个文件中。
3. **源码位置查找**（`--loc filename:line[:col]`）：解析该位置处的符号，适用于局部变量、被遮蔽的名称和有歧义的符号。同时给出行号和列号时，可以省略单独的 `<symbol>` 参数。

### 示例

```
$ moon ide peek-def Agent
Found 1 symbols matching 'Agent':

`pub (all) struct Agent` in package moonbitlang/maria/agent at ./agent/agent.mbt:17-47

17 | ///|
   | /// Represents an AI agent that interacts with language models and executes tools.
...|
   | pub(all) struct Agent {
...|
...| }
```



```
$ moon ide peek-def Agent --loc ./maria.mbt:7
Definition found at file ./maria/agent/agent.mbt
   | ///
   | /// The `Agent` struct encapsulates the complete state and behavior of an AI agent,
...|
24 | pub(all) struct Agent {
   |                 ^^^^^
   |   /// UUID generator for creating unique identifiers.
...|
```



## `moon ide find-references` - 追踪所有用法

了解一个符号在整个代码库中的使用位置和方式。

### 用法

```
moon ide find-references <symbol>
moon ide find-references <token> --loc <path[:line[:col]]>
moon ide find-references --loc <path:line:col>
```



不带 `--loc` 时，该命令会在当前模块或工作区中搜索语义符号。文件形式和源码位置形式的行为与 `peek-def` 相同，并支持局部变量和被遮蔽的名称。

默认不包含定义。添加 `--include-definition` 可将其包含在内。使用 `--json` 时，每个结果还包含 `is_test` 字段，用于标识测试块和测试文件中的引用。

### 示例

```
$ moon ide find-references Agent --include-definition
`pub (all) struct Agent` in package moonbitlang/maria/agent at ./agent/agent.mbt:17-47
17 | ///|
   | /// Represents an AI agent that interacts with language models and executes tools.
...|
   | pub(all) struct Agent {
...|
...| }
Found 98 references of this symbol:
./agent/agent_tool.mbt:41:8-41:13:
   | /// * `agent` : The agent instance whose tools will be enabled or disabled.
   | /// * `tool_names` : A set containing the names of tools that should be enabled.
   | ///   Tools not in this set will be disabled.
41 | pub fn Agent::set_enabled_tools(
   |        ^^^^^
   |   agent : Agent,
   |   tool_names : Set[String],
...
```



## `moon ide codelens` - 获取引用 CodeLens

返回源码文件中顶层声明的局部引用和全局引用 CodeLens 条目：

```
moon ide codelens path/to/file.mbt
```



输出始终为 JSON 数组。局部引用的位置包含 `is_test` 字段，范围使用从 1 开始的 `行:列-行:列` 位置。

## `moon ide outline` - 获取结构概览

快速扫描文件或包的结构，理解其组织方式。

### 用法

```
moon ide outline <path/to/file_or_directory>
```



两种模式：

- `moon ide outline path/to/file.mbt` - 查看单个文件的结构
- `moon ide outline path/to/directory` - 查看包内所有 `.mbt` 文件的结构

### 示例

**包结构** - 查看所有文件及其顶层符号：

```
moon ide outline .
maria.mbt:
 L05 | pub struct Maria {
       ...
 L71 | pub fn Maria::close(self : Maria) -> Unit {
       ...
 L84 | pub async fn Maria::start(self : Maria, prompt? : String) -> Unit {
```



**文件结构** - 查看单个文件的详细结构：

```
$ moon ide outline ./internal/readline/readline.mbt
 L0002 | priv struct Edit {
         ...
 L0008 | pub enum KeyName {
         ...
 L0045 | pub struct Key {
         ...
 L1369 | pub async fn Interface::start(self : Interface) -> Unit {
         ...
 L1383 | pub async fn Interface::read_line(self : Interface) -> String {
         ...
 L1390 | pub async fn Interface::read_key(self : Interface) -> Key {
         ...
```



## `moon ide doc` - 发现与探索 API

查询文档并发现可用的符号、包和 API。

### 用法

```
moon ide doc '<query>'
```



### 查询语法

查询语法专门用于符号和包的发现：

**空查询** - 列出可用包或符号：

- `moon ide doc ''`
  - 在模块内：显示所有可用包（包括依赖和 `moonbitlang/core`）
  - 在包内：显示当前包中的所有符号
  - 在包外：显示所有可用包

**按名称查找：**

- `moon ide doc "[@pkg.]function_name"` - 查找函数或值
- `moon ide doc "[@pkg.]TypeName"` - 查找类型（内建类型不需要前缀）
- `moon ide doc "[@pkg.]Type::member"` - 查找类型方法或字段

**包探索：**

- `moon ide doc "@pkg"` - 列出一个包中所有导出符号
- `moon ide doc "@encoding/utf8"` - 支持嵌套包
- 示例：`moon ide doc "@json"`、`moon ide doc "@buffer"`

**通配匹配（Globbing）** - 使用 `*` 通配符进行部分匹配：

- `moon ide doc "String::*rev*"` - 查找名称中包含 "rev" 的所有 String 方法
- `moon ide doc "*parse*"` - 查找名称中包含 "parse" 的所有符号

### 示例

**搜索类型方法：**

```
# Search for String methods in standard library:
$ moon ide doc "String"

type String

  pub fn String::add(String, String) -> String
  # ... more methods omitted ...
```



**探索一个包：**

```
$ moon ide doc "@buffer"
moonbitlang/core/buffer

fn from_array(ArrayView[Byte]) -> Buffer
# ... omitted ...
```



**查询特定函数：**

```
$ moon ide doc "@buffer.new"
package "moonbitlang/core/buffer"

pub fn new(size_hint? : Int32) -> Buffer
  Creates ... omitted ...
```



**使用通配匹配查找相关函数：**

```
$ moon ide doc "String::*rev*"
package "moonbitlang/core/string"

pub fn String::rev(String) -> String
  Returns ... omitted ...
  # ... more

pub fn String::rev_find(String, StringView) -> Int32?
  Returns ... omitted ...
```

# MoonBit VSCode 插件

MoonBit 为 Visual Studio Code 提供了一个插件，可以在 [Visual Studio 市场](https://marketplace.visualstudio.com/items?itemName=moonbit.moonbit-lang) 和 [Open VSX 仓库](https://open-vsx.org/extension/moonbit/moonbit-lang) 中找到。

## 命令

该插件提供了几个命令，可以通过 [命令面板](https://code.visualstudio.com/docs/getstarted/userinterface#_command-palette) 访问

- 选择后端：它允许你在多个后端之间切换
- 重启 MoonBit 语言服务器：它允许你重启语言服务器，以防它无响应或有一些过时的状态。
- 安装 MoonBit 工具链：手动触发安装过程。该扩展将检查已安装的 MoonBit 工具链是否与扩展的版本匹配。
- 获取 LSP 的编译器版本：它将显示扩展使用的 MoonBit 编译器版本。
- 切换多行字符串：帮助在纯文本与 MoonBit 的 [多行字符串语法](https://docs.moonbitlang.cn/language/fundamentals.html#string) 之间切换所选文本。

## 操作

该插件还提供了几个操作，可以通过 [快速修复](https://code.visualstudio.com/docs/editing/refactoring#_code-actions-quick-fixes-and-refactorings) 访问

- 添加缺失的分支：当遇到 [错误 0011](https://docs.moonbitlang.cn/language/error_codes/E0011.html) 时，它允许你填充 `match` 表达式的分支

## 代码透镜

该插件为每个顶级代码块，特别是测试块，提供代码透镜。

提供的功能包括：

- 格式化：格式化代码块
- 测试 / 基准：测试或基准测试代码块
- 调试（仅限 JavaScript 后端）：使用调试器测试测试块
- 更新：更新代码块中的 [快照测试](https://docs.moonbitlang.cn/language/tests.html#snapshot-tests)
- 跟踪：打开/关闭测试块的跟踪，其中每个赋值将在其旁边呈现值

# WebAssembly 集成

MoonBit 是一种提供对 WebAssembly 进行一流支持的编程语言。

## 组件模型

查看 [本教程](https://docs.moonbitlang.cn/toolchain/wasm/component-model-tutorial.html) 了解如何在 MoonBit 中使用 [组件模型](https://component-model.bytecodealliance.org/)。

## 自定义导出和导入

查看 [FFI](https://docs.moonbitlang.cn/language/ffi.html) 部分，了解如何导入或导出函数。

## 问与答

1. 问：什么是 `spectest.print_char`

   A: 这是 MoonBit 打印的方式。它一次打印一个 UTF-16 Unicode 代码。为了可移植性，避免使用 `println`。如果这确实出现在最终结果中，请考虑使用 [`wasm-merge`](https://github.com/WebAssembly/binaryen) 或类似工具。

# MoonBit 与组件模型

本指南演示了如何使用 MoonBit 构建 WebAssembly 组件，利用 WIT（WebAssembly 接口类型）进行接口定义，并使用 `wit-bindgen` 工具链进行代码生成。

本教程将演示如何构建一个实现 `docs:adder` 包中定义的 [`adder` world][adder-wit] 的组件。该组件将导出一个包含两个数字求和的 `add` 函数的 `add` 接口。

## 1. Install the Tools

### 安装 MoonBit

首先，安装 MoonBit 编译器和工具链。请按照 [MoonBit 下载页面](https://www.moonbitlang.cn/download) 的说明进行操作。

验证你的 MoonBit 安装（以下是撰写本文时的版本）：

```
$ moon version --all
moon 0.1.20250826 (8ab6c9e 2025-08-26) ~/.moon/bin/moon
moonc v0.6.25+d6913262c (2025-08-27) ~/.moon/bin/moonc
moonrun 0.1.20250826 (8ab6c9e 2025-08-26) ~/.moon/bin/moonrun
moon-pilot 0.0.1-95f12db ~/.moon/bin/moon-pilot
```



### 安装 Wasm 工具链

1. 安装 `wit-bindgen` CLI 工具，它可以从 WIT 文件生成 MoonBit 绑定：

   ```
   $ cargo install wit-bindgen-cli
   ```

   

2. 为了使用 WebAssembly 组件，安装 `wasm-tools`：

   ```
   $ cargo install wasm-tools
   ```

   

验证安装（以下是撰写本文时的版本）：

```
$ wit-bindgen --version
wit-bindgen-cli 0.45.0
$ wasm-tools --version
wasm-tools 1.238.0
```



## 2. Define the Interface (WIT)

在生成 MoonBit 项目之前，你需要使用 WIT 定义组件接口。为你的项目创建一个目录并定义 WIT 文件：

```
mkdir moonbit-adder && cd moonbit-adder
mkdir wit
```



创建 `wit/world.wit`，内容如下：

```
package docs:adder@0.1.0;

interface add {
    add: func(x: u32, y: u32) -> u32;
}

world adder {
    export add;
}
```



此 WIT 定义：

- 声明一个包 `docs:adder`，版本为 `0.1.0`
- 定义一个 `add` 接口，包含一个接受两个 `u32` 参数并返回一个 `u32` 的函数
- 创建一个 `adder` 世界，导出 `add` 接口

## 3. Generate MoonBit Project Structure

使用 `wit-bindgen` 生成 MoonBit 项目结构和绑定：

```
wit-bindgen moonbit wit/world.wit --out-dir . \
    --derive-eq \
    --derive-show \
    --derive-error
```



对于仍会生成遗留 `moon.mod.json` 格式的版本，请在生成的项目中运行一次 `moon fmt`，将其迁移为 `moon.mod`。迁移后的目录结构如下：

```
.
├── ffi
│   ├── moon.pkg
│   └── top.mbt
├── gen
│   ├── ffi.mbt
│   ├── gen_interface_docs_adder_add_export.mbt
│   ├── interface
│   │   └── docs
│   │       └── adder
│   │           └── add
│   │               ├── moon.pkg
│   │               ├── stub.mbt
│   │               └── top.mbt
│   ├── moon.pkg
│   ├── world
│   │   └── adder
│   │       ├── moon.pkg
│   │       └── stub.mbt
│   └── world_adder_export.mbt
├── moon.mod
├── wit
│   └── world.wit
└── world
    └── adder
        ├── ffi_import.mbt
        ├── import.mbt
        ├── moon.pkg
        └── top.mbt
```



生成的文件包括：

- `moon.mod`：MoonBit 模块配置
- `gen/`: 生成的导出绑定
  - `interface/`: 生成的导出接口绑定
  - `world/`: 生成的导出世界绑定
  - `stub.mbt`: 主实现文件
- `interface/`: 生成的导入接口绑定
- `world/`: 生成的导入世界绑定

## 4. Examine the Generated Code

`wit-bindgen` 工具生成了处理 WebAssembly 组件接口的 MoonBit 绑定。让我们检查生成的 `gen/interface/docs/adder/add/stub.mbt`：

```
// Generated by `wit-bindgen` 0.45.0.

pub fn add(_x : UInt32, _y : UInt32) -> UInt32 {
      ...
}
```



`...` 是 MoonBit 中的占位符语法。当执行 `moon check --target wasm` 时，会出现“未完成代码”警告。

## 5. Implement the Component Logic

现在在 `gen/interface/docs/adder/add/stub.mbt` 中实现 `add` 函数：

```
// Generated by `wit-bindgen` 0.45.0.

///|
pub fn add(x : UInt32, y : UInt32) -> UInt32 {
  x + y
}
```



## 6. Configure the Build

确保你的 `gen/moon.pkg` 已正确配置为 WebAssembly 目标：

gen/moon.pkg

```
import {
  "docs/adder/ffi",
  "docs/adder/gen/interface/docs/adder/add",
}

options(
  link: {
    "wasm": {
      "exports": [
        "cabi_realloc:cabi_realloc",
        "wasmExportAdd:docs:adder/add@0.1.0#add",
      ],
      "export-memory-name": "memory",
      "heap-start-address": 16,
    },
  },
)
```



## 7. Build the WebAssembly Component

将 MoonBit 代码构建为 WebAssembly：

```
moon build --target wasm
```



这将生成一个 WebAssembly 模块。为了创建一个合适的 WebAssembly 组件，使用 `wasm-tools`：

```
wasm-tools component embed wit _build/wasm/release/build/gen/gen.wasm \
    --encoding utf16 \
    --output adder.wasm
wasm-tools component new adder.wasm --output adder.component.wasm
```



你可以使用 `wasm-tools` 验证组件的接口：

```
wasm-tools component wit adder.component.wasm
```



期待的两个命令输出：

```
package root:component;

world root {
  export docs:adder/add@0.1.0;
}
package docs:adder@0.1.0 {
  interface add {
    add: func(x: u32, y: u32) -> u32;
  }
}
```



## 8. Testing the Component

### 使用示例宿主

要测试你的组件，请使用本存储库中提供的 [`example-host`][example-host]：

```
git clone https://github.com/bytecodealliance/component-docs.git
cd component-docs/component-model/examples/example-host
cp /path/to/adder.component.wasm .
cargo run --release -- 5 3 adder.component.wasm
```



期待的输出：

```
5 + 3 = 8
```



### 使用 Wasmtime

你也可以直接使用 `wasmtime` 测试组件：

```
wasmtime run --invoke 'add(10, 20)' adder.component.wasm
30
```



## 9. Configurations

### --derive-eq --derive-show

这两个选项将为所有生成的类型添加 `derive(Eq)` 和 / 或 `derive(Show)`。

### --derive-error

此选项将生成名称中包含“Error”的变体/枚举作为 [suberrors](https://docs.moonbitlang.com/en/latest/language/error-handling.html#error-types)。这使你能够更轻松地集成 MoonBit 的错误处理。

例如，对于以下接口：

```
package docs:adder@0.1.0;

interface add {
    variant computation-error {
        overflow
    }
    add: func(x: u32, y: u32) -> result<u32, computation-error>;
}

world adder {
    import add;
}
```



将生成以下类型和函数：

```
// Generated by `wit-bindgen` 0.45.0. DO NOT EDIT!

///|
pub(all) suberror ComputationError {
  Overflow
} derive(Show, Eq)

///|
pub fn add(x : UInt32, y : UInt32) -> Result[UInt32, ComputationError] {
  ...
}
```



你可以这样使用它：

```
// Generated by `wit-bindgen` 0.45.0.

///|
fn init {
  let _ = @add.add(1, 2).unwrap_or_error() catch { Overflow => ... }

}
```



### --ignore-stub

当你想要由于更新接口而重新生成项目时，但又不想修改 `stub` 文件时，就会发生这种情况。你可以使用 `--ignore-stub` 选项来避免这种修改。

### --project-name

默认情况下，项目名称是根据 MoonBit 文件中定义的名称生成的。你可以使用此选项来指定项目的名称。如果你正在将项目作为更大项目的一部分生成，它也可以使用。

### --gen-dir

默认情况下，导出部分生成在 `gen` 下。你可以使用此选项指定另一个目录。

## 10. References and Further Reading

- [WebAssembly Component Model](https://component-model.bytecodealliance.org/)
- [Component Model Examples](https://github.com/bytecodealliance/component-docs/tree/main/component-model/examples)
- [WIT Format Specification](https://component-model.bytecodealliance.org/design/wit.html)
- [`wit-bindgen`](https://github.com/bytecodealliance/wit-bindgen)
- [WebAssembly Tools](https://github.com/bytecodealliance/wasm-tools)
- [Wasmtime Runtime](https://wasmtime.dev/)

# 数独求解器

数独是一种基于逻辑的益智游戏，起源于 1979 年。它非常适合报纸等印刷媒体，即使在数字时代，许多数独游戏程序也可用于计算机和智能手机。尽管如今娱乐选择多种多样，但数独爱好者仍在继续组建活跃的在线社区。本文将演示如何使用 MoonBit 编写合适的程序来解决数独问题。

## 方格、单元和同级

最常见的数独形式是在 9x9 网格上进行的。我们将从上到下的行标记为 A-I，从左到右的列标记为 1-9。这为网格中的每个方格提供了一个坐标，例如，下面网格中包含数字 0 的方格的坐标为 C3。

```
  1 2 3 4 5 6 7 8 9
A . . . . . . . . .
B . . . . . . . . .
C . . 0 . . . . . .
D . . . . . . . . .
E . . . . . . . . .
F . . . . . . . . .
G . . . . . . . . .
H . . . . . . . . .
I . . . . . . . . .
```



这个 9x9 的网格共有 9 个单元，每个单元包含的方格必须具有从 1 到 9 的唯一数字。但是在游戏的初始状态下，大多数方格不包含任何数字。

```
 4  1  7 | 3  6  9 | 8  2  5
 6  3  2 | 1  5  8 | 9  4  7
 9  5  8 | 7  2  4 | 3  1  6
---------+---------+---------
 8  2  5 | 4  3  7 | 1  6  9
 7  9  1 | 5  8  6 | 4  3  2
 3  4  6 | 9  1  2 | 7  5  8
---------+---------+---------
 2  8  9 | 6  4  3 | 5  7  1
 5  7  3 | 2  9  1 | 6  8  4
 1  6  4 | 8  7  5 | 2  9  3
```



除了单元之外，另一个重要概念是同级。一个方格的同级包括同一行、同一列和同一单位的其他方格。例如，C2 的同级包括以下方格：

```
    A2   |         |
    B2   |         |
    C2   |         |
---------+---------+---------
    D2   |         |
    E2   |         |
    F2   |         |
---------+---------+---------
    G2   |         |
    H2   |         |
    I2   |         |

         |         |
         |         |
 C1 C2 C3| C4 C5 C6| C7 C8 C9
---------+---------+---------
         |         |
         |         |
         |         |
---------+---------+---------
         |         |
         |         |
         |         |

 A1 A2 A3|         |
 B1 B2 B3|         |
 C1 C2 C3|         |
---------+---------+---------
         |         |
         |         |
         |         |
---------+---------+---------
         |         |
         |         |
         |         |
```



没有两个同级的格子可以包含相同的数字。

我们需要一个数据类型 Grid[T] 来存储这 81 个方格以及与每个方格相关的信息。这可以使用哈希表来实现，但使用数组会更紧凑、更简单。首先，我们编写一个函数将坐标 A1-I9 转换为索引 0-80：

```
// A1 => 0, A2 => 1
fn square_to_int(s : String) -> Int32 {
  if s is [('A'..='I') as a, ('1'..='9') as b, ..] {
    let row = a.to_int() - 'A'.to_int() // 'A' <=> 0
    let col = b.to_int() - '1'.to_int() // '1' <=> 0
    return row * 9 + col
  } else {
    abort("Grid_to_int(): \{s} is not a Grid")
  }
}

///
test {
  inspect(square_to_int("A1"), content="0")
  inspect(square_to_int("A7"), content="6")
  inspect(square_to_int("I9"), content="80")
}
```



接下来，我们封装这个数组，并为 `Grid[T]` 提供创建、访问特定坐标、为特定坐标赋值和复制等操作。通过为访问方法添加索引别名，可以方便地编写 `table["A2"]` 和 `table["C3"] = ...` 这样的代码。

```
///|
struct Grid[T](FixedArray[T])

///|
fn[T] Grid::new(val : T) -> Grid[T] {
  FixedArray::make(81, val)
}

///|
fn[T] Grid::copy(self : Grid[T]) -> Grid[T] {
  if self.0.length() == 0 {
    return []
  }
  let arr = FixedArray::make(81, self.0[0])
  let mut i = 0
  while i < 81 {
    arr[i] = self.0[i]
    i = i + 1
  }
  return arr
}

///|
#alias("_[_]")
fn[T] Grid::at(self : Grid[T], square : String) -> T {
  let i = square_to_int(square)
  self.0[i]
}

///|
#alias("_[_]=_")
fn[T] Grid::set(self : Grid[T], square : String, x : T) -> Unit {
  let i = square_to_int(square)
  self.0[i] = x
}
```



接下来我们准备一些常量：

```
let rows = "ABCDEFGHI"

let cols = "123456789"

type Squares =  @immut/sorted_set.SortedSet[String] 

// squares contains the coordinates of each square
let squares : Squares = ......

// units[coord] contains the other squares in the unit of the square at coord
// for example：units["A3"] => [C3, C2, C1, B3, B2, B1, A2, A1]
let units : Grid[Squares] = ......

// peers[coord] contains all the peers of the square at coord
// for example：peers["A3"] => [A1, A2, A4, A5, A6, A7, A8, A9, B1, B2, B3, C1, C2, C3, D3, E3, F3, G3, H3, I3]
let peers : Grid[Squares] = ......
```



构建单元和同级表的过程非常繁琐，因此这里不再详述。

## 预处理网格

我们使用字符串来表示初始数独网格。各种格式均可接受；. 和 0 均表示空方块，其他字符（如空格和换行符）将被忽略。

```
#|400000805
#|030000000
#|000700000
#|020000060
#|000080400
#|000010000
#|000603070
#|500200000
#|104000000

#|4 . .   . . .   8 . 5
#|. 3 .   . . .   . . .
#|. . .   7 . .   . . .
#|
#|. 2 .   . . .   . 6 .
#|. . .   . 8 .   4 . .
#|. . .   . 1 .   . . .
#|
#|. . .   6 . 3   . 7 .
#|5 . .   2 . .   . . .
#|1 . 4   . . .   . . .
```



暂时先不考虑太多游戏规则，如果只考虑每个方格能填入的数字，那么 1-9 都是有可能的，因此我们初始将所有方格的内容设置为`['1', '2', '3', '4', '5', '6', '7', '8', '9']` (a List)。

```
fn Grid::parse(s : String) -> Grid[@immut/sorted_set.SortedSet[Char]] {
  let digits = @immut/sorted_set.SortedSet(cols.to_array())
  let values = Grid::new(digits)
  ...
}
```



接下来，我们需要将输入中已知数字的方块赋值。这个过程可以用函数 `assign(values, key, val)` 来实现，其中 `key` 是一个字符串，比如 `A6`，`val` 是一个字符。这样的代码写起来很容易。

```
fn assign(values : Grid[@immut/sorted_set.SortedSet[Char]], key : String, val : Char) -> Unit {
  values[key] = @immut/sorted_set.singleton(val)
}
```



这个实现简单而精确，但我们可以做得更多。

现在，我们可以重新引入之前搁置的规则。但是，规则本身并没有告诉我们该做什么。我们需要启发式策略来从规则中获得见解，类似于用笔和纸解决数独。让我们从消除法开始：

- **策略 1**：如果为一个方块 `key` 分配了一个值 `val`，则其对同级（'peers[key]'）的可能值列表中不应该包含 `val'，因为这会违反同一单元、行或列中没有两个方块可以具有相同数字的规则。
- **策略 2**：如果一个单元中只有一个方格可以容纳特定的数字（在多次应用上述规则后可能发生），则应将该数字分配给该方格。

我们通过定义一个消除函数 `eliminate` 来调整代码，该函数从正方形的可能值中删除一个数字。执行消除任务后，它将上述策略应用于 `key` 和 `val` 以尝试进一步消除。请注意，它包含一个布尔返回值来处理可能的矛盾。如果方格的可能值列表为空，则出现问题，我们返回 `false`。

```
fn eliminate(
  values : Grid[@sorted_set.SortedSet[Char]],
  key : String,
  val : Char
) -> Bool {
  if !(values[key].contains(val)) {
    return true
  }
  values[key] = values[key].remove(val)
  // If `key` has only one possible value left, remove this value from its peers
  match values[key].length() {
    1 => {
      let val = values[key].min()
      let mut res = true
      for key in peers[key] {
        res = res && eliminate(values, key, val)
      }
      if !res {
        return res
      }
    }
    0 => return false
    _ => ()
  }
  //  If there is only one square in the unit of `key` that can hold `val`, assign `val` to that square
  let unit = units[key]
  let places = unit.filter(fn(sq) { values[sq].contains(val) })
  match places.length() {
    1 => {
      let key = places.min()
      return assign(values, key, val)
    }
    0 => return false
    _ => return true
  }
}
```



接下来，我们定义 `assign(values, key, val)` 来从 `key` 的可能值中删除除 `val` 之外的所有值。

```
///|
fn assign(
  values : Grid[@sorted_set.SortedSet[Char]],
  key : String,
  val : Char
) -> Bool {
  let other_values = values[key].remove(val)
  let mut result = true
  for val in other_values {
    result = result && eliminate(values, key, val)
  }
  return result
}
```



这两个函数将启发式策略应用于它们访问的每个方格。成功的启发式应用会引入新的方格供考虑，从而使这些策略在整个网格中广泛传播。这是快速消除无效选项的关键。事实上，这种预处理已经可以解决一些简单的数独难题。

```
let grid2 =
  #|0 0 3   0 2 0   6 0 0
  #|9 0 0   3 0 5   0 0 1
  #|0 0 1   8 0 6   4 0 0
  #|
  #|0 0 8   1 0 2   9 0 0
  #|7 0 0   0 0 0   0 0 8
  #|0 0 6   7 0 8   2 0 0
  #|
  #|0 0 2   6 0 9   5 0 0
  #|8 0 0   2 0 3   0 0 9
  #|0 0 5   0 1 0   3 0 0

test {
  inspect(
    Grid::parse(grid2).format(),
    content=(
      #| 4  8  3 | 9  2  1 | 6  5  7
      #| 9  6  7 | 3  4  5 | 8  2  1
      #| 2  5  1 | 8  7  6 | 4  9  3
      #|---------+---------+---------
      #| 5  4  8 | 1  3  2 | 9  7  6
      #| 7  2  9 | 5  6  4 | 1  3  8
      #| 1  3  6 | 7  9  8 | 2  4  5
      #|---------+---------+---------
      #| 3  7  2 | 6  8  9 | 5  1  4
      #| 8  1  4 | 2  5  3 | 7  6  9
      #| 6  9  5 | 4  1  7 | 3  8  2
      #|
    ),
  )
}
```



如果您对人工智能感兴趣，您可能会将其视为约束满足问题 (CSP)，而'分配'和'消除'是专门的弧一致性算法。有关此主题的更多信息，请参阅 Artificial Intelligence: A Modern Approach 第 6 章

## 搜索

经过预处理后，我们可以大胆地使用蛮力枚举来搜索所有可行的组合。但是，在搜索过程中，我们仍然可以使用启发式策略。当尝试为某个方块赋值时，我们仍然使用 `assign`，这使我们能够应用先前的优化来消除搜索过程中的许多无效分支。

另外需要注意的是，搜索过程中可能会发生冲突（当一个方格的可能值耗尽时）。由于可变结构使回溯变得麻烦，因此我们每次分配值时都直接复制值。

```
fn search(
  values : Grid[@sorted_set.SortedSet[Char]],
) -> Grid[@sorted_set.SortedSet[Char]]? {
  if values.contains(fn(digits) { !(digits.length() == 1) }) {
    let mut minsq = ""
    let mut n = 10
    for sq in squares {
      let len = values[sq].length()
      if len > 1 {
        if len < n {
          n = len
          minsq = sq
        }
      }
    }
    for digit in values[minsq] {
      let another = values.copy()
      if assign(another, minsq, digit) {
        let temp = search(another)
        match temp {
          None => continue
          Some(v) => return Some(v)
        }
      }
    } nobreak {
      return None
    }
  } else {
    return Some(values)
  }
}

fn solve(g : String) -> String {
  match search(Grid::parse(g)) {
    None => "can't solve \{g}"
    Some(v) => v.format()
  }
}
```



我们运行一个来自 [magictour](http://magictour.free.fr/top95) （一个困难数独谜题列表，对人类来说并不容易）的例子

```
let grid1 =
  #|4 . .   . . .   8 . 5
  #|. 3 .   . . .   . . .
  #|. . .   7 . .   . . .
  #|
  #|. 2 .   . . .   . 6 .
  #|. . .   . 8 .   4 . .
  #|. . .   . 1 .   . . .
  #|
  #|. . .   6 . 3   . 7 .
  #|5 . .   2 . .   . . .
  #|1 . 4   . . .   . . .

test {
  inspect(
    solve(grid1),
    content=(
      #| 4  1  7 | 3  6  9 | 8  2  5
      #| 6  3  2 | 1  5  8 | 9  4  7
      #| 9  5  8 | 7  2  4 | 3  1  6
      #|---------+---------+---------
      #| 8  2  5 | 4  3  7 | 1  6  9
      #| 7  9  1 | 5  8  6 | 4  3  2
      #| 3  4  6 | 9  1  2 | 7  5  8
      #|---------+---------+---------
      #| 2  8  9 | 6  4  3 | 5  7  1
      #| 5  7  3 | 2  9  1 | 6  8  4
      #| 1  6  4 | 8  7  5 | 2  9  3
      #|
    ),
  )
}
```



在普通开发机器上，求解这个数独只需要约 0.11 秒。

## 总结

游戏的目的是为了缓解无聊并带来快乐。如果玩游戏让人感到焦虑而不是兴奋，那么它可能违背了游戏设计师的初衷。本文表明，简单的消除法和强力搜索可以快速解决一些数独难题。这并不意味着数独不值得玩；相反，它表明人们不应该过分担心无法解决的数独难题。

让我们轻松玩转 MoonBit 吧！

本教程参考了 Peter Norvig 的数独求解文章。

# Lambda 演算

相信点开这篇文章的您或多或少地听说过函数式编程这个名词。在摩尔定律失效的今天，对多核处理器的充分利用成为了一种越发重要的程序优化方法，而函数式编程也因为其并行运算亲和的特点在大众视野中越发频繁地出现。究其原因，离不开它从其理论上的祖先之一 - lambda 演算那里所继承的特征。

而 lambda 演算这一起源于 20 世纪 30 年代，出自图灵导师阿隆佐·邱奇之手的形式系统如今已经发展成了蔚为大观的一个大家族，本文将展示其中最基础的一种：无类型 lambda 演算 (这也是最早阿隆佐·邱奇提出的那种)

## 无类型 lambda 演算的基本规则

无类型 lambda 演算中能做的事情只有定义 lambda (经常称为 Abstraction) 和调用 lambda (经常称为 Application)，它们也是 lambda 演算中的基础表达式。

由于函数式编程范式对主流编程语言的影响，大多数程序员对 lambda 表达式这个名字已经不会感到陌生了，不过，无类型 lambda 演算中的 lambda 要比主流编程语言简单一些。一个 lambda 通常看起来就像这样：`λx.x x`, 其中 x 是它的参数 (每个 lambda 只能有一个参数)，`.`是分隔参数与表达式具体定义的分隔符，后面的`x x`便是它的定义了。

备注

也有些材料的记法不写空格，上面的例子要改写成 `λx.xx`

上面的 `x x` 如果换成 `x(x)`, 可能更符合我们在一般语言中见到的函数调用。但在 lambda 演算较常见的写法中，调用一个 lambda 只需要在它和它的参数中间写个空格。此处我们调用 `x` 所给出的参数就是 `x` 自己。

以上两种表达式和定义 lambda 时引入的变量加在一起合称 lambda 项，我们在 MoonBit 里用一个 enum 类型来表示它：

```
enum Term {
  Var(String) // 变量
  Abs(String, Term) // 定义 lambda，变量用字符串表示
  App(Term, Term) // 调用 lambda
}
```



我们在日常编程中所接触的概念诸如布尔值，if 表达式，自然数算术乃至递归都可以通过 lambda 表达式实现，但这并非本文内容的重心所在。

参见

有兴趣的读者可以参阅 [Programming with Nothing](https://tomstu.art/programming-with-nothing) 这篇博客。

要实现一个无类型 lambda 演算的解释器，我们所需要了解的基本就只有两条规则：Alpha 转换与 Beta 规约。

Alpha 转换所描述的事实是，lambda 的结构是重点，变量名叫什么没那么重要。`λx.x` 和 `λfoo.foo` 可以互相替换。对于某些有重复变量名的嵌套 lambda 例如 `λx.(λx.x) x`，重命名时不能把内层的变量也重命名了，例如上面的例子可以通过 Alpha 转换写成 `λy.(λx.x) y`。

Beta 规约则专注于处理 lambda 的调用，还是举一个例子：

```
(λx.(λy.x)) (λs.(λz.z))
```



在无类型 lambda 演算中，调用 lambda 之后所需要作的事情仅仅是对参数进行替换 (substitution)，上面这个例子里就需要把变量 `x` 替换成 `(λs.(λz.z))`，得到的结果是

```
(λy.(λs.(λz.z)))
```



## 自由变量与变量捕获

一个 lambda 项中的变量如果在它所处的上下文中没有定义，那么我们叫它自由变量。例如 `(λx.(λy.fgv h))` 这个 lambda 项中变量 `fgv` 和 `h` 就没有对应的 lambda 定义。

在进行 Beta 规约时，如果用于替换变量的那个 lambda 项中含有自由变量，可能会导致一种被称为“变量捕获”的行为

```
(λx.(λy.x)) (λz.y)
```



上面这个表达式在替换后会变成

```
λy.λz.y
```



`λz.y` 中的自由变量被当成了某个 lambda 的参数，这显然不是我们想要的。

变量捕获问题在编写解释器时的常见解决方案是在替换前遍历表达式得到一个自由变量的集合，做替换时遇到内层 lambda 就判断一下变量名在不在这个自由变量集合里面

```
// (λx.E) T => E.subst(x, T)
fn subst(self : Term, var : String, term : Term) -> Term {
  let freeVars : Set[String] = term.get_free_vars()
  match self {
    Abs(variable, body) => {
      if freeVars.contains(variable) {
        //自由变量集合中有当前这个内层 lambda 的参数名，即会发生变量捕获
        abort("subst(): error while encountering \{variable}")
      } else {
        ...
      }
    }
    ...
  }
}
```



此处我们介绍一种较少见但具有一定便利性的方法：德布朗指数（de Bruijn index）。

## 德布朗指数

德布朗指数是一种用整数表示 lambda 项中变量的技术，具体地说，它用变量所在位置和原先引入它的位置中间有几层 lambda 来替换特定变量。

```
λx.(λy.x (λz.z z))

λ.(λ.1 (λ.0 0))
```



上面的例子中，变量 `x` 和引入它的地方 `λx` 中间有一个 `λy`, 于是将 `x` 替换为 `1`，而 `z` 和定义它的位置中间没有夹杂其他的 lambda，于是直接用 `0` 替换。某种程度上说，德布朗指数的值描述的是变量与对应 lambda 的相对距离，此处的距离衡量标注就是中间嵌套的 lambda 层数。

备注

同一个变量在不同的地方可能会用不同的整数来替换。

我们定义一个新类型 `TermDBI` 来表示使用德布朗指数的 lambda 项：

```
enum TermDBI {
  Var(String, Int32)
  Abs(String, TermDBI)
  App(TermDBI, TermDBI)
}
```



不过直接编写以及阅读德布朗指数形式的 lambda 很痛苦，所以我们需要编写一个将 `Term` 转换成 `TermDBI` 的函数 `debruijn()` - 这也是 `TermDBI` 类型定义中仍有 `String` 的原因，保留原变量名可用于它的 `Show` 的实现，这样就可以方便地用 `println` 打印求值结果查看了。

```
impl Show for TermDBI with output(self, logger) -> Unit {
  match self {
    Var(name, _) => logger.write_string(name)
    Abs(name, body) => logger.write_string("(\\\{name}.\{body})")
    App(t1, t2) => logger.write_string("\{t1} \{t2}")
  }
}
```



为了简化实现，如果输入的 Term 中含有自由变量，`debruijn()` 函数会直接报错。MoonBit 中一般用 `Result[V, E]` 类型表示可能会出错的计算，它有 `Ok(V)` 和 `Err(E)` 两个值构造子，分别代表计算成功与失败。

提示

使用过 Rust 语言的读者应该会感到熟悉。

```
fn bruijn(self : Term) -> Result[TermDBI, String]
```



我们采取一种笨办法来保存变量名与相关联的嵌套深度，首先定义 `Index` 类型

```
struct Index {
  name : String
  depth : Int32
}
```



然后写一个从 `@list.List[Index]` 中根据特定 `name` 查找对应 `depth` 的辅助函数

```
// Find the depth corresponding to the first varname in the environment
fn find(map : @list.List[Index], varname : String) -> Result[Int32, String] {
  match map {
    Empty => Err(varname)
    More(i, tail=rest) =>
      if i.name == varname {
        Ok(i.depth)
      } else {
        find(rest, varname)
      }
  }
}
```



现在可以补全 `debruijn()` 函数了。

- `Var` 的处理最简单，只需要查表寻找对应 `depth` 即可。
- `Abs` 稍微复杂一点，首先对列表中所有 `index` 的 `depth` 加一 (因为 lambda 嵌套加深了一层)，然后在列表的开头加上 `{ name : varname, depth : 0 }`。
- `App` 在两个子项都能转换时成功，否则返回一个 `Err`

```
fn go(m : @list.List[Index], term : Term) -> Result[TermDBI, String] {
  match term {
    Var(name) => {
      let idx = find(m, name)
      match idx {
        Err(name) => Err(name)
        Ok(idx) => Ok(Var(name, idx))
      }
    }
    Abs(varname, body) => {
      let m = m
        .map(fn(index) { { name: index.name, depth: index.depth + 1 } })
        .prepend({ name: varname, depth: 0 })
      let res = go(m, body)
      match res {
        Err(name) => Err(name)
        Ok(term) => Ok(Abs(varname, term))
      }
    }
    App(e1, e2) =>
      match (go(m, e1), go(m, e2)) {
        (Ok(e1), Ok(e2)) => Ok(App(e1, e2))
        (Err(name), _) => Err(name)
        (_, Err(name)) => Err(name)
      }
  }
}

go(@list.List([]), self)
```



## 在 `TermDBI` 上做规约

规约主要处理的是 `App`，即调用：

```
fn TermDBI::eval(self : TermDBI) -> TermDBI {
  match self {
    App(t1, t2) =>
      match (t1.eval(), t2.eval()) {
        (Abs(_, t1), t2) => subst(t1, t2).eval()
        (t1, t2) => App(t1, t2)
      }
    Abs(_) => self
    // Eval should not encounter any free variables
    _ => panic()
  }
}
```



首先对两个子项尝试规约，然后看 `eval(t1)` 得到的是否是一个 lambda，如果是，就执行一步变量替换 (通过 `subst` 函数) 然后继续化简。对于 lambda (即 `Abs`), 直接原样返回即可。

`subst` 函数的实现在不用考虑自由变量的情况下简单了许多，只要记录递归到当前位置的深度并且与遇到的变量进行比对，大小相等就是需要替换的目标变量。

```
fn subst(t1 : TermDBI, t2 : TermDBI) -> TermDBI {
  fn go(t1 : TermDBI, t2 : TermDBI, depth : Int32) -> TermDBI {
    match t1 {
      Var(_, d) => if d == depth { t2 } else { t1 }
      Abs(name, t) => Abs(name, go(t, t2, depth + 1))
      App(tl, tr) => App(go(tl, t2, depth), go(tr, t2, depth))
    }
  }

  go(t1, t2, 0)
}
```



完整代码在 [这里](https://docs.moonbitlang.cn/_downloads/6fe10fa2705f6ab126995fece1061096/top.mbt)

## 改进

笔者在保存变量名到索引的对应关系时使用了 `@list.List[Index]` 类型，并且在每增加一层 lambda 时更新整个列表，但是这其实是个很笨的办法。相信聪明且注意力集中的读者很快就能发现，其实只需要保存一个 `@list.List[String]` 就够了，有兴趣的读者可以自己试着做一做。

# G-Machine

惰性求值是编程语言领域的一个基本概念。Haskell 作为一种纯粹的函数式编程语言而闻名，它拥有健壮的惰性求值机制。这种机制不仅使开发人员能够编写更高效、更简洁的代码，而且还增强了程序的性能和响应能力，特别是在处理大型数据集或复杂的数据流时。

在本文中，我们将深入研究惰性求值机制，全面研究其原理和实现方法，然后探索如何在 [MoonBit](https://www.moonbitlang.com/) 中实现 Haskell 的求值语义。

目录：

- G-Machine 第一部分
  - [高阶函数和性能挑战](https://docs.moonbitlang.cn/example/gmachine/gmachine-1.html#higher-order-functions-and-performance-challenges)
  - [惰性列表实现](https://docs.moonbitlang.cn/example/gmachine/gmachine-1.html#lazy-list-implementation)
  - [一种惰性求值语言及其抽象语法树](https://docs.moonbitlang.cn/example/gmachine/gmachine-1.html#a-lazy-evaluation-language-and-its-abstract-syntax-tree)
  - [为什么是图](https://docs.moonbitlang.cn/example/gmachine/gmachine-1.html#why-graph)
  - [约定](https://docs.moonbitlang.cn/example/gmachine/gmachine-1.html#conventions)
  - [G-Machine 概述](https://docs.moonbitlang.cn/example/gmachine/gmachine-1.html#g-machine-overview)
  - [G-Machine 状态解析](https://docs.moonbitlang.cn/example/gmachine/gmachine-1.html#dissecting-the-g-machine-state)
  - [每条指令的作用](https://docs.moonbitlang.cn/example/gmachine/gmachine-1.html#corresponding-effect-of-each-instruction)
  - [将超组合子编译成指令序列](https://docs.moonbitlang.cn/example/gmachine/gmachine-1.html#compiling-super-combinators-into-instruction-sequences)
  - [运行 G-Machine](https://docs.moonbitlang.cn/example/gmachine/gmachine-1.html#running-the-g-machine)
  - [总结](https://docs.moonbitlang.cn/example/gmachine/gmachine-1.html#conclusion)
  - [参考](https://docs.moonbitlang.cn/example/gmachine/gmachine-1.html#reference)
- G-Machine 第二部分
  - [let 表达式](https://docs.moonbitlang.cn/example/gmachine/gmachine-2.html#let-expressions)
  - [添加原语](https://docs.moonbitlang.cn/example/gmachine/gmachine-2.html#adding-primitives)
  - [总结](https://docs.moonbitlang.cn/example/gmachine/gmachine-2.html#conclusion)
- G-Machine 第三部分
  - [追踪上下文](https://docs.moonbitlang.cn/example/gmachine/gmachine-3.html#tracking-context)
  - [自定义数据结构](https://docs.moonbitlang.cn/example/gmachine/gmachine-3.html#custom-data-structures)
  - [结语](https://docs.moonbitlang.cn/example/gmachine/gmachine-3.html#epilogue)

# G-Machine 第一部分

本文是关于在 MoonBit 中实现惰性求值的系列文章的第一篇。在本文中，我们将探讨惰性求值的目的以及用于惰性求值的典型抽象机器 G-Machine。

## 高阶函数和性能挑战

高阶函数，如 `map` 和 `filter`，通常是许多人对函数式编程的第一印象（尽管函数式编程远不止于这些函数）。它们简化了许多列表处理任务，但另一个问题出现了：这些高阶函数嵌套太深可能会导致性能不佳（因为它需要多次遍历列表）。

为了提高代码效率，一些人提出利用基于高阶函数内部重复模式的编译器优化。例如，将 `map(f, map(g, list))` 重写为：

```
map(fn (x) { f(g(x)) }, list)
```



尝试不错，但重要的是要认识到这种优化技术具有固有的局限性，特别是在处理更复杂的场景时。将所有处理合并到一个函数中可以避免重复的列表遍历，但它会对降低代码的可读性，并使修改变得复杂。是否有一种更平衡的解决方案，兼顾效率和可维护性？

惰性求值是一种技术，可以在这种情况下在一定程度上减少不必要的成本。这种策略可以集成到特定的数据结构中（例如，Java 8 中添加的 Stream 类型，以及早期 Scheme 语言中的 stream），或者整个语言可以被设计为惰性（成功的例子包括 20 世纪 80 年代的 Miranda 语言，以及后来的 Haskell 和 Clean 语言）。

首先，让我们探讨一下惰性列表（`Stream`）如何避免在这种情况下多次遍历。

备注

这里的 `List[T]` 是 `@list.List[T]` 的类型别名。

## 惰性列表实现

首先，让我们定义它的类型：

```
enum Stream[T] {
  Empty
  Cons(T, () -> Stream[T])
}
```



`Stream[T]` 和 `List[T]` 之间唯一的真正区别在于 `Cons`：保存列表其余部分的位置被一个无参数函数（俗称为 thunk）替换。这是惰性求值的一个简单实现：将不想立即计算的东西包装在一个 thunk 中。

我们还需要一个函数将常规列表转换为惰性列表：

```
fn[T] Stream::from_list(l : List[T]) -> Self[T] {
  match l {
    Empty => Empty
    More(x, tail=xs) => Cons(x, fn() { Stream::from_list(xs) })
  }
}
```



这个函数不需要遍历整个列表来将其转换为 `Stream`。对于不急着要结果的运算（这里是 `Stream::from_list(xs)`），我们直接将它们包装在一个 thunk 中并返回。下面的 `map` 函数将采用这种方法（不过这里的 `xs` 已经是一个 thunk 了）。

```
fn[X, Y] Stream::map(self : Stream[X], f : (X) -> Y) -> Stream[Y] {
  match self {
    Empty => Empty
    Cons(x, xs) => Cons(f(x), fn() { xs().map(f) })
  }
}
```



`take` 函数负责执行计算，它可以根据需要提取 n 个元素。

```
fn[T] Stream::take(self : Stream[T], n : Int32) -> List[T] {
  if n == 0 {
    @list.List([])
  } else {
    match self {
      Empty => @list.List([])
      Cons(x, xs) => xs().take(n - 1).prepend(x)
    }
  }
}
```



使用 thunk 实现惰性数据结构的方法很简单，有效地解决了上述问题。这种方法要求用户明确指示代码中应该延迟计算的位置，而惰性语言的策略则更加激进：它默认使用惰性求值来处理所有用户定义的函数！在接下来的章节中，我们将介绍一个惰性函数式语言的最小实现，并简要介绍其潜在的理论模型。

## 一种惰性求值语言及其抽象语法树

本文中使用的示例是一种惰性求值语言，故意设计成类似 Clojure（一种 Lisp 方言）的语言，命名为 coreF。这是为了在 Markdown 中使用 Clojure 的语法高亮。请别担心，语法可能有点麻烦，但是绝对够简单。

使用 `defn` 关键字定义函数：

```
(defn factorial[n] ;; n 是参数，这个函数计算 n 的阶乘
  (if (eq n 0) ;; 定义从这里开始，持续到下面的三行
    1
    (mul n (factorial (sub n 1)))))
```



在一般对话中，我们将它成为函数就好。但当我们讨论惰性函数式语言时，我们必须引入一个专门的术语：*超组合子*（Super Combinator ）。在超组合子的定义中，所有自由变量都应该包含在一个初始的 `[]` 中。

coreF 程序的执行从 `main` 开始，调用一个特定的超组合子，等价于用它的定义替换它。

```
(defn main[] (factorial 42))
```



没有参数的超组合子，如 `main`，有一个术语：*常量应用形式（Constant Applicative Forms，简称 CAF）*。

coreF 还具有几个语言特性，包括自定义数据结构、用于解构的 `case` 表达式，以及用于声明局部变量的 `let` 和 `letrec`。但是，本文的范围仅限于上述特性（实际上，甚至更少，因为像 `eq`、`mul`、`sub` 等内置函数之后才会实现）。

coreF 不包括匿名函数，因为匿名函数会引入额外的自由变量。删除它们需要额外的转换步骤：lambda 提升。这种技术可以将 lambda 表达式转换为外部超组合子，但这不是惰性求值的主要内容，因此在这里省略了。

超组合子最终将被解析为 `ScDef[String]`，但编写解析器是一项繁琐的任务。我将在最终代码中提供它。

```
enum RawExpr[T] {
  Var(T)
  Num(Int32)
  Constructor(tag~ : Int32, arity~ : Int32) // tag, arity
  App(RawExpr[T], RawExpr[T])
  Let(Bool, List[(T, RawExpr[T])], RawExpr[T]) // isRec, Defs, Body
  Case(RawExpr[T], List[(Int32, List[T], RawExpr[T])])
} derive(Debug)

pub extend RawExpr with @moonbitlang/core/debug.Debug::{to_repr}

struct ScDef[T] {
  name : String
  args : List[T]
  body : RawExpr[T]
} derive(Debug)

pub extend ScDef with @moonbitlang/core/debug.Debug::{to_repr}
```



此外，还有一些预定义的 coreF 程序需要给出。

```
let prelude_defs : List[ScDef[String]] = {
  let args : (FixedArray[String]) -> List[String] = x => @list.List(x)
  let id = ScDef::new("I", args(["x"]), Var("x")) // id x = x
  let k = ScDef::new("K", args(["x", "y"]), Var("x")) // K x y = x
  let k1 = ScDef::new("K1", args(["x", "y"]), Var("y")) // K1 x y = y
  let s = ScDef::new(
    "S",
    args(["f", "g", "x"]),
    App(App(Var("f"), Var("x")), App(Var("g"), Var("x"))),
  ) // S f g x = f x (g x)
  let compose = ScDef::new(
    "compose",
    args(["f", "g", "x"]),
    App(Var("f"), App(Var("g"), Var("x"))),
  ) // compose f g x = f (g x)
  let twice = ScDef::new(
    "twice",
    args(["f"]),
    App(App(Var("compose"), Var("f")), Var("f")),
  ) // twice f = compose f f
  @list.List([id, k, k1, s, compose, twice])
}
```



## 为什么是图

在 coreF 语言中，表达式（不是前面提到的 `RawExpr[T]`，而是运行时表达式）在被求值时，以图的形式存储在内存中，而不是树。

为什么要这样？看看这个程序：

```
(defn square[x]  (mul x x))
(defn main[] (square (square 3)))
```



如果我们按照一般的树形表达式来求值，表达式会被规约成：

```
(mul (square 3) (square 3))
```



在这种情况下，`(square 3)` 将被计算两次，这对于惰性求值来说显然是不可取的。

为了更清楚地说明这一点，让我们用 MoonBit 代码做一个不太恰当的类比：

```
fn square(thunk : () -> Int32) -> Int32 {
  thunk() * thunk()
}
```



使用图来表示程序是为了方便共享计算结果，避免冗余计算。为了实现这个目的，在减少图时实现一个原地更新算法是至关重要的。关于原地更新，让我们用 MoonBit 代码来模拟它：

```
///|
enum LazyData[T] {
  Waiting(() -> T)
  Done(T)
}

///|
struct LazyRef[T] {
  mut data : LazyData[T]
}

///|
fn[T] LazyRef::extract(self : LazyRef[T]) -> T {
  match self.data {
    Waiting(thunk) => {
      let value = thunk()
      self.data = Done(value) // 原地更新
      value
    }
    Done(value) => value
  }
}

///|
fn square(x : LazyRef[Int32]) -> Int32 {
  x.extract() * x.extract()
}
```



无论哪一方先执行 `extract` 方法，它都会更新引用的可变字段，并用计算结果替换其内容。因此，在第二次执行 `extract` 方法时无需重新计算。

## 约定

在讨论图规约如何进行之前，让我们先定义一些术语和基本事实。我们将继续使用相同的程序作为示例：

```
(defn square[x]  (mul x x)) ;; 乘法
(defn main[] (square (square 3)))
```



- 内置的原语，如 `mul`，是预定义的操作。

- 对表达式进行求值（当然是惰性的），并原地更新图中对应的节点，这个过程称为规约。
- `(square 3)` 是一个可规约的表达式（reducible expression，通常缩写为 redex），由 `square` 和它的参数组成。它可以规约为 `(mul 3 3)`。`(mul 3 3)` 也是一个 redex，但与 `(square 3)` 相比，它是一种不同类型的 redex，因为 `square` 是一个用户定义的组合子，而 `mul` 是一个实现的内置原语。
- `(mul 3 3)` 的规约结果是表达式 `9`，它不能进一步规约。这种不能进一步规约的表达式称为范式（normal form）。
- 一个表达式可能包含多个子表达式（例如 `(mul (add 3 5) (mul 7 9))`）。在这种情况下，表达式的规约顺序至关重要——有些程序只在特定的规约顺序下停机。

- 有一种特殊的规约顺序总是选择最外层的 redex 进行规约，称为 *正则序规约*（normal order reduction）。下文也将统一采用这种规约顺序。

因此，图规约可以用以下伪代码描述：

```
当图中存在可规约的表达式时 {
    选择最外层的可规约表达式。
    规约表达式。
    用规约的结果更新图。
}
```



头晕了吗？让我们找一些例子来演示如何在纸上进行规约。

### 第一步：找到下一个 redex

在整个程序中，执行从 `main` 函数开始。

```
(defn square[x]  (mul x x))
(defn main[] (add 33 (square 3)))
```



`main` 本身是一个 CAF - 最简单的 redex。如果我们进行替换，当前要处理的表达式是：

```
(add 33 (square 3))
```



根据找到最外层 redex 的原则，我们似乎立即找到了由 `add` 和它的两个参数组成的 redex（暂时这么假设）。

但是稍等！由于存在默认的柯里化，这个表达式对应的抽象语法树实际上由多个 `App` 节点嵌套而成。它大致看起来是这样的（为了可读性而简化）：

```
App(App(add, 33), App(square, 3))
```



这个从 `add` 到最外层 `App` 节点的链式结构称为“脊柱”（Spine）

回过头来看一下，`add` 是一个内部定义的原语。但是，由于它的第二个参数 `(square 3)` 不是范式，我们不能对它进行规约（将一个未求值的表达式加到一个整数上似乎有点荒谬）。因此，我们不能明确地说 `(add 33 (square 3))` 是一个 redex；它只是最外层的函数应用。要对它进行规约，我们必须先规约 `(square 3)`。

### 第二步：规约

因为 `square` 是一个用户定义的超组合子，所以对 `(square 3)` 进行规约只涉及参数替换。

如果一个 redex 的参数比超组合子所需的参数——这在高阶函数中很常见——它就成为一个 `弱头部范式`（weak head normal form，通常缩写为 WHNF）。在这种情况下，即使它的子表达式包含 redex，也无需处理。以「对列表中的所有整数执行三倍化」为例。

```
(map (mul 3) list-of-int)
```



在这里，`(mul 3)` 不能被视为 redex，因为它缺少足够的参数。

### 第三步：更新

这一步只影响执行效率，在纸上推导时可以跳过。

这些操作在纸上执行很容易（当代码量不超过半张纸时），但当我们切换到计算机时，我们如何将这些步骤转换为可执行代码呢？

为了回答这个问题，惰性求值编程语言的先驱们提出了各种用于建模惰性求值的 **抽象机器**。这些包括：

- G-Machine
- 三指令机器
- ABC Machine（由 Clean 语言使用）
- Spineless Tagless G-Machine（简称 STG，由 Haskell 语言使用）

这些执行模型用于指导编译器实现。需特别注意，与当下主流的虚拟机（如 JVM）不同，抽象机器更像是编译器的中间表示（IR）。以 Haskell 的编译器 GHC 为例，生成 STG 代码后，它不会直接将其传递给解释器执行。相反，它会根据所选的后端进一步将其转换为 LLVM、C 代码或机器代码。

为了简化实现，本文将直接使用 MoonBit 为 G-Machine 指令编写解释器，从一个最小的示例开始，逐渐添加更多功能。

## G-Machine 概述

虽然 G-Machine 是用于惰性函数式语言的抽象机器，但其结构和概念与编写一般命令式语言时遇到的情况并无显著差异。它也有堆和栈等结构，其指令是顺序执行的。一些关键的区别包括：

- 堆中的内存的基本单位不是字节，而是图节点。
- 栈只包含指向堆的指针，而不是实际数据。

> 这种设计可能不太实用，但相对简单。

coreF 中的超组合子被编译成一系列 G-Machine 指令。这些指令大致可以分为以下几类：

- 访问数据指令，例如 `PushArg`（访问函数参数）和 `PushGlobal`（访问其他超组合子）。
- 在堆中构造/更新图节点，如 `MkApp`、`PushInt`、`Update`
- 用于清理栈中未使用的地址的 `Pop` 指令。
- 用于表示控制流的 `Unwind` 指令。

## G-Machine 状态解析

在这个简单版本的 G-Machine 中，状态包括：

- 堆：这是存储表达式图和与超组合子对应的指令序列的地方。

  ```
  /// Use the struct tuple to encapsulate an address type.
  struct Addr(Int32) derive(Eq, Debug)
  
  pub extend Addr with Eq::{not_equal, equal}
  
  pub extend Addr with @moonbitlang/core/debug.Debug::{to_repr}
  
  /// Describe graph nodes with an enumeration type.
  enum Node {
    NNum(Int32)
    // The application node
    NApp(Addr, Addr)
    // To store the number of parameters and 
    // the corresponding sequence of instructions for a super combinator
    NGlobal(String, Int32, List[Instruction])
    // The Indirection node. The key component of implementing lazy evaluation
    NInd(Addr)
  } derive(Eq, Debug)
  
  pub extend Node with Eq::{not_equal, equal}
  
  pub extend Node with @moonbitlang/core/debug.Debug::{to_repr}
  
  struct GHeap {
    // The heap uses an array, 
    // and the space with None content in the array is available as free memory.
    mut object_count : Int32
    memory : Array[Node?]
  }
  
  /// Allocate heap space for nodes.
  fn GHeap::alloc(self : GHeap, node : Node) -> Addr {
    let heap = self
    fn next(n : Int32) -> Int32 {
      (n + 1) % heap.memory.length()
    }
  
    fn free(i : Int32) -> Bool {
      match heap.memory[i] {
        None => true
        _ => false
      }
    }
  
    let mut i = heap.object_count
    while !free(i) {
      i = next(i)
    }
    heap.memory[i] = Some(node)
    heap.object_count = heap.object_count + 1
    return Addr(i)
  }
  ```

  

- 栈：栈只保存指向堆的地址。一个简单的实现可以使用 `List[Addr]`。

- 全局表：它是一个映射表，记录超组合子（包括预定义的和用户定义的）的名称及其对应的 `NGlobal` 节点的地址。这里我使用 Robin Hood 哈希表实现。

- 当前要执行的代码序列。

- 执行状态统计：一个简单的实现涉及计算已执行了多少条指令。

整个状态使用类型 `GState` 表示。

```
struct GState {
  mut stack : List[Addr]
  heap : GHeap
  globals : @hashmap.HashMap[String, Addr]
  mut code : List[Instruction]
  mut stats : GStats
}

struct GStats(Int32)

fn GState::stat_incr(self : GState) -> Unit {
  self.stats = self.stats.0 + 1
}

fn GState::put_stack(self : GState, addr : Addr) -> Unit {
  self.stack = self.stack.prepend(addr)
}

fn GState::put_code(self : GState, instrs : List[Instruction]) -> Unit {
  self.code = instrs + self.code
}

fn GState::pop1(self : GState) -> Addr {
  match self.stack {
    More(addr, tail=reststack) => {
      self.stack = reststack
      addr
    }
    Empty => abort("pop1(): stack size smaller than 1")
  }
}

// e1 e2 ..... -> (e1, e2) ......
fn GState::pop2(self : GState) -> (Addr, Addr) {
  match self.stack {
    More(addr1, tail=More(addr2, tail=reststack)) => {
      self.stack = reststack
      (addr1, addr2)
    }
    _ => abort("pop2(): stack size smaller than 2")
  }
}
```



现在，我们可以将我们在纸上推导的图规约算法一一对应到这个抽象机器：

- 在机器的初始状态下，所有已编译的超组合子均以 `NGlobal` 节点的形式分配在堆上。此时，G-Machine 中的当前代码序列只包含两条指令。第一条指令将 `main` 节点的地址压入栈中，第二条指令将 `main` 的对应代码序列加载到当前代码序列中。
- `main` 对应的代码序列在堆上实例化，此时会分配节点并加载相应数据，最终在内存中构建一个图。该过程被称为“实例化” `main`。一旦实例化完成，该图的入口地址将被压入栈中。
- 实例化完成后，进行清理工作，包括更新图节点（因为 `main` 没有参数，所以不需要清理栈中残留的未使用地址）并找到下一个 redex。

所有这些任务都有对应的指令实现。

## 每条指令的作用

目前，这个高度简化的 G-Machine 包含 7 条指令。

```
enum Instruction {
  Unwind
  PushGlobal(String)
  PushInt(Int32)
  PushArg(Int32)
  MkApp
  Update(Int32)
  Pop(Int32)
} derive(Eq, Debug)

pub extend Instruction with Eq::{not_equal, equal}

pub extend Instruction with @moonbitlang/core/debug.Debug::{to_repr}
```



`PushInt` 指令是最简单的。它在堆上分配一个 `NNum` 节点，并将其地址压入栈中。

```
fn GState::push_int(self : GState, num : Int32) -> Unit {
  let addr = self.heap.alloc(NNum(num))
  self.put_stack(addr)
}
```



`PushGlobal` 指令从全局表中检索指定超组合子的地址，然后将地址压入栈中。

```
fn GState::push_global(self : GState, name : String) -> Unit {
  guard self.globals.get(name) is Some(addr) else {
    abort("push_global(): can't find supercombinator \{name}")
  }
  self.put_stack(addr)
}
```



`PushArg` 指令稍微复杂一些。它对栈上地址的布局有特定要求：第一个地址应指向超组合子节点，接着是 n 个指向 N `NApp` 节点的地址。`PushArg` 从 `offset + 1` 开始检索第 N 个参数。

```
fn GState::push_arg(self : GState, offset : Int32) -> Unit {
  let appaddr = self.stack.unsafe_nth(offset + 1)
  let arg = match self.heap[appaddr] {
    NApp(_, arg) => arg
    otherwise =>
      abort(
        "pusharg: stack offset \{offset} address \{@debug.to_string(appaddr)} node \{@debug.to_string(otherwise)}",
      )
  }
  self.put_stack(arg)
}
```



`MkApp` 指令从栈顶取出两个地址，构造一个 `NApp` 节点，并将其地址压入栈中。

```
fn GState::mk_apply(self : GState) -> Unit {
  let (a1, a2) = self.pop2()
  let appaddr = self.heap.alloc(NApp(a1, a2))
  self.put_stack(appaddr)
}
```



`Update` 指令假设栈上的第一个地址指向当前 redex 的求值结果。它跳过紧随其后的超组合子节点的地址，并用指向求值结果的间接节点替换第 N 个 `NApp` 节点。如果当前 redex 是一个 CAF，它直接替换堆上对应的 `NGlobal` 节点。由此，我们可以看到为什么在惰性函数式语言中，无参函数和普通变量之间没有太大区别。

```
fn GState::update(self : GState, n : Int32) -> Unit {
  let addr = self.pop1()
  let dst = self.stack.unsafe_nth(n)
  self.heap[dst] = NInd(addr)
}
```



G-Machine 中的 `Unwind` 指令类似于一个求值循环。该指令根据栈顶地址对应的节点类型，存在多个分支条件：

- `Nnum` 节点：什么也不做。
- `NApp` 节点：将左节点的地址推送到栈上，然后再次 `Unwind`。
- `NGlobal` 节点：如果栈上有足够的参数，将这个超组合子加载到当前代码中。
- `NInd` 节点：将这个间接节点中包含的地址推送到栈上，然后再次 `Unwind`。

```
fn GState::unwind(self : GState) -> Unit {
  let addr = self.pop1()
  match self.heap[addr] {
    NNum(_) => self.put_stack(addr)
    NApp(a1, _) => {
      self.put_stack(addr)
      self.put_stack(a1)
      self.put_code(@list.List([Unwind]))
    }
    NGlobal(_, n, c) =>
      if self.stack.length() < n {
        abort("Unwinding with too few arguments")
      } else {
        self.put_stack(addr)
        self.put_code(c)
      }
    NInd(a) => {
      self.put_stack(a)
      self.put_code(@list.List([Unwind]))
    }
  }
}
```



`Pop` 指令弹出 N 个地址，无需单独的函数实现。

## 将超组合子编译成指令序列

在 G-Machine 概述部分，我们大致描述了编译超组合子的行为。现在我们可以精确地描述超组合子的编译过程。

首先，在执行编译的超组合子的指令序列之前，栈中必须已经存在某些地址：

- 栈顶的地址指向一个 `NGlobal` 节点（超组合子本身）。
- 接下来是 N 个地址（N 是这个超组合子的参数数量），指向一系列 App 节点 - 正好对应一个 redex 的脊柱。栈底的地址指向表达式的最外层 App 节点，其余的依次类推。

在编译超组合子时，我们需要维护一个环境，便于在编译过程中，通过名称找到参数在栈中的相对位置。此外，由于超组合子的实例化完成后需要清除前面的 N+1 个地址，所以需要传递参数数量 N。

> 这里，“参数”指的是指向堆上 App 节点的地址，实际参数地址可以通过 `PushArg` 指令访问。

```
fn ScDef::compileSC(self : ScDef[String]) -> (String, Int32, List[Instruction]) {
  let name = self.name
  let body = self.body
  let mut arity = 0
  fn gen_env(i : Int32, args : List[String]) -> List[(String, Int32)] {
    match args {
      Empty => {
        arity = i
        return @list.List([])
      }
      More(s, tail=ss) => gen_env(i + 1, ss).prepend((s, i))
    }
  }

  let env = gen_env(0, self.args)
  (name, arity, body.compileR(env, arity))
}
```



`compileR` 函数通过调用 `compileC` 函数生成实例化超组合子的代码，然后附加三条指令：

- `Update(N)`: 将堆中原始 redex 更新为一个 `NInd` 节点，然后指向新实例化的超组合子。
- `Pop(N)`: 清除栈中多余的地址。
- `Unwind`: 寻找下一个 redex，开始下一轮规约。

```
fn RawExpr::compileR(
  self : RawExpr[String],
  env : List[(String, Int32)],
  arity : Int32
) -> List[Instruction] {
  if arity == 0 {
    self.compileC(env) + @list.List([Update(arity), Unwind])
  } else {
    self.compileC(env) + @list.List([Update(arity), Pop(arity), Unwind])
  }
}
```



在编译超组合子的定义时，使用了一种相当粗糙的方法：如果一个变量不是参数，那么它被视为另一个超组合子（写错了会导致运行时错误）。对于函数应用，首先编译右侧表达式，然后增加环境中对应参数的所有偏移量（因为栈顶增加了一个指向实例化的右侧表达式的额外地址），然后编译左侧表达式，最后添加 `MkApp` 指令。

```
fn RawExpr::compileC(
  self : RawExpr[String],
  env : List[(String, Int32)]
) -> List[Instruction] {
  match self {
    Var(s) =>
      match env.lookup(s) {
        None => @list.List([PushGlobal(s)])
        Some(n) => @list.List([PushArg(n)])
      }
    Num(n) => @list.List([PushInt(n)])
    App(e1, e2) =>
      e2.compileC(env) +
      e1.compileC(argOffset(1, env)) +
      @list.List([MkApp])
    _ => abort("not support yet")
  }
}
```



## 运行 G-Machine

一旦超组合子被编译，需要将它们置于堆上（并将它们的地址添加到全局表中）。这可以递归完成。

```
fn build_initial_heap(
  scdefs : List[(String, Int32, List[Instruction])],
) -> (GHeap, @hashmap.HashMap[String, Addr]) {
  let heap = { object_count: 0, memory: Array::make(10000, None) }
  let globals = @hashmap.HashMap([], capacity=50)
  for scdefs = scdefs {
    match scdefs {
      Empty => break
      More((name, arity, instrs), tail=rest) => {
        let addr = heap.alloc(NGlobal(name, arity, instrs))
        globals[name] = addr
        continue rest
      }
    }
  }
  return (heap, globals)
}
```



定义一个函数 "step"，它通过一步更新 G-Machine 的状态，如果已经到达最终状态，则返回 false。

```
fn GState::step(self : GState) -> Bool {
  match self.code {
    Empty => return false
    More(i, tail=rest) => {
      self.code = rest
      self.stat_incr()
      match i {
        PushGlobal(f) => self.push_global(f)
        PushInt(n) => self.push_int(n)
        PushArg(n) => self.push_arg(n)
        MkApp => self.mk_apply()
        Unwind => self.unwind()
        Update(n) => self.update(n)
        Pop(n) => self.stack = self.stack.drop(n)
      }
      return true
    }
  }
}
```



此外，定义一个函数 "reify"，它不断执行 "step" 函数，直到到达最终状态。

```
fn GState::reify(self : GState) -> Node {
  if self.step() {
    self.reify()
  } else {
    let stack = self.stack
    match stack {
      More(addr, tail=Empty) => {
        let res = self.heap[addr]
        return res
      }
      _ => abort("wrong stack \{@debug.to_string(stack)}")
    }
  }
}
```



将上述各部分组合起来。

```
fn run(codes : List[String]) -> Node {
  fn parse_then_compile(code : String) -> (String, Int32, List[Instruction]) {
    let tokens = tokenize(code)
    let code = try tokens.parse_sc() catch {
      ParseError(s) => abort(s)
    } noraise {
      expr => expr
    }
    let code = code.compileSC()
    return code
  }

  let codes = codes.map(parse_then_compile) + prelude_defs.map(ScDef::compileSC)
  let (heap, globals) = build_initial_heap(codes)
  let initialState : GState = {
    heap,
    stack: @list.List([]),
    code: @list.List([PushGlobal("main"), Unwind]),
    globals,
    stats: 0,
  }
  GState::reify(initialState)
}
```



## 总结

到目前为止，我们构建的 G-Machine 的功能十分有限，甚至无法运行一个像样的程序。在下一篇文章中，我们将逐步添加诸如原语和自定义数据结构等功能。最后，我们将在介绍 G-Machine 后引入惰性求值技术。

## 参考

Peyton Jones, Simon & Lester, David. (2000). Implementing functional languages: a tutorial.

# G-Machine 第二部分

本文是 MoonBit 实现惰性求值系列的第二篇。在第一篇中，我们探讨了惰性求值的目的，介绍了典型的惰性求值抽象机器 G-Machine 并实现了它的一些基本指令。在本文中，我们将延续前文基础，进一步扩展 G-Machine 的实现以支持 `let` 表达式及基础算术，比较等运算。

## let 表达式

coreF 中的 `let` 表达式与 MoonBit 略有差异。MoonBit 的 `let` 表达式可以创建多个变量，但只能在有限的范围内使用。示例如下：

```
{
  let x = n + m
  let y = x + 42
  x * y
}
```



对应的 coreF 表达式：

```
(let ([x (add n m)]
      [y (add x 42)])
  (mul x y)) ;; xy can only be used within let
```



需要注意 coreF 中的 `let` 表达式必须按顺序执行，如下代码是无效的：

```
(let ([y (add x 42)]
      [x (add n m)])
  (mul x y))
```



相比之下，`letrec` 允许本地变量不考虑定义顺序下相互引用，从而更加复杂。

在实现 `let`（和更复杂的 `letrec`）表达式之前，我们首先需要修改当前的参数传递方法。`let` 创建的本地变量应该像参数一样访问，但 `let` 中的本地变量不对应 NApp 节点，因此我们需要在调用超组合子之前调整栈参数。

该调整在执行 `Unwind` 指令的过程中完成。如果超组合子没有参数，则与原始 `unwind` 相同。当存在参数时，超组合子节点的顶部地址会被丢弃，并开始调用 `rearrange` 函数。

```
fn GState::rearrange(self : GState, n : Int32) -> Unit {
  let appnodes = self.stack.take(n)
  let args = appnodes.map(fn(addr) {
    guard! self.heap[addr] is NApp(_, arg)
    arg
  })
  self.stack = args + appnodes.drop(n - 1)
}
```



`rearrange` 函数假设堆栈上的前 N 个地址指向一系列 `NApp` 节点。它保留最底部的地址（用于 Redex 更新），清理栈顶的 N-1 个地址，然后将 N 个地址放置在栈中，这些地址直接指向参数。

在这之后，通过将 `PushArg` 指令更改为更通用的 `Push` 指令，参数和局部变量都可以使用相同的命令进行访问。

```
fn GState::push(self : GState, offset : Int32) -> Unit {
  // Push(n) a0 : . . . : an : s
  //     =>  an : a0 : . . . : an : s
  let addr = self.stack.unsafe_nth(offset)
  self.put_stack(addr)
}
```



接下来我们需要清理一些不再使用的数据或状态，考虑以下表达式：

```
(let ([x1 e1]
      [x2 e2])
  expr)
```



在构建与表达式 expr 对应的图之后，栈中仍然包含指向 e1 和 e2 的地址（分别对应变量 x1 和 x2）,如下所示（栈从下到上增长）

```
<Address pointing to expr>
       |
<Address pointing to x2>
       |
<Address pointing to x1>
       |
...remaining stack...
```



因此，我们需要一个新的指令来清理这些不再需要的地址。它被称为 `Slide`。顾名思义，`Slide(n)` 的功能是跳过第一个地址并删除以下 N 个地址

```
fn GState::slide(self : GState, n : Int32) -> Unit {
  let addr = self.pop1()
  self.stack = self.stack.drop(n).prepend(addr)
}
```



现在我们来使用 let 表达式，我们将用 compileC 函数编译与本地变量对应的表达式。然后，遍历变量定义（`defs`）列表，依次编译并更新相应的偏移量。最后，使用传入的 `comp` 函数编译主表达式，并添加 `Slide` 指令来清理不使用的地址。

> 使用传入的函数编译主表达式，有助于在后续添加新功能时实现代码的高效复用。

```
fn compileLet(
  comp : (RawExpr[String], List[(String, Int32)]) -> List[Instruction],
  defs : List[(String, RawExpr[String])],
  expr : RawExpr[String],
  env : List[(String, Int32)],
) -> List[Instruction] {
  let (env, codes) = for env = env, acc = @list.List([]), remaining = defs {
    match remaining {
      Empty => break (env, acc)
      More((name, expr), tail=rest) => {
        let code = expr.compileC(env)
        let env = argOffset(1, env).prepend((name, 0))
        continue env, acc + code, rest
      }
    }
  }
  codes + comp(expr, env) + @list.List([Slide(defs.length())])
}
```



`letrec`的语义更加复杂——它允许表达式中的 N 个变量相互引用，因此我们需要预先分配 N 个地址并将其放置在堆栈上。我们需要一个新的指令：`Alloc（N）`，它预先分配 N 个`NInd`节点，并将地址顺序推送到堆栈上。这些间接节点中的地址是负数，仅用作占位符。

```
fn GState::alloc_nodes(self : GState, n : Int32) -> Unit {
  let dummynode : Node = NInd(Addr(-1))
  for i = 0; i < n; i = i + 1 {
    let addr = self.heap.alloc(dummynode)
    self.put_stack(addr)
  }
}
```



`letrec`的用法与`let`语句类似

- 使用`Alloc(n)`来分配 N 个节点
- 使用`loop`表达式构建一个完整的环境
- 在`defs`中编译本地变量，然后使用`Update`指令将结果更新到预先分配好的地址。
- 编译主表达式，并使用`Slide`指令进行清理。

```
fn compileLetrec(
  comp : (RawExpr[String], List[(String, Int32)]) -> List[Instruction],
  defs : List[(String, RawExpr[String])],
  expr : RawExpr[String],
  env : List[(String, Int32)],
) -> List[Instruction] {
  let mut env = env
  for remaining = defs {
    match remaining {
      Empty => break
      More((name, _), tail=rest) => {
        env = argOffset(1, env).prepend((name, 0))
        continue rest
      }
    }
  }
  let n = defs.length()
  fn compileDefs(
    defs : List[(String, RawExpr[String])],
    offset : Int32,
  ) -> List[Instruction] {
    match defs {
      Empty => comp(expr, env) + @list.List([Slide(n)])
      More((_, expr), tail=rest) =>
        expr.compileC(env) +
        compileDefs(rest, offset - 1).prepend(Update(offset))
    }
  }

  compileDefs(defs, n - 1).prepend(Alloc(n))
}
```



## 添加原语

从这步开始，我们终于可以开始执行基本的整数运算，如算术、比较与检查两个数字是否相等。首先，修改 `Instruction`类型以添加相关指令。

```
  Add
  Sub
  Mul
  Div
  Neg
  Eq // ==
  Ne // !=
  Lt // <
  Le // <=
  Gt // >
  Ge // >=
  Cond(List[Instruction], List[Instruction])
```



实现这些指令乍看上去似乎很简单。以`Add`为例：只需从栈中弹出两个地址，获取对应的数字，执行加法操作，然后把结果的地址推回栈中。

```
fn add(self : GState) -> Unit {
  let (a1, a2) = self.pop2() // Pop two top addresses
  match (self.heap[a1], self.heap[a2]) {
    (NNum(n1), NNum(n2)) => {
      let newnode = Node::NNum(n1 + n2)
      let addr = self.heap.alloc(newnode)
      self.putStack(addr)
    }
    ......
  }
}
```



然而，接下来我们面临的问题是：这是一个惰性求值的语言。在惰性求值中，传递给 `add` 的参数很可能还没有被计算（即它们可能不是 `NNum `节点，而是尚未计算的表达式）。因此，我们需要一种指令来强制执行计算，确保获取结果，或者在某些情况下，保证计算不会停下来。我们称之为 `Eval`（即 Evaluation 缩写）。

> 在术语中，这种计算的结果称为弱头范式（WHNF）。

同时我们需要修改 `GState` 的架构并加入 `dump` 的状态，类型是 `List[(List[Instruction], List[Addr])]`，使用 `Eval` 和 `Unwind` 指令的功能

执行`Eval`指令并不复杂

- 弹出堆栈的顶部地址
- 保存当前未执行的指令序列和栈（通过将它们放入 `dump` 中）
- 清空当前栈并放入先前保存的地址。
- 清空当前的指令序列，并放入 `Unwind `指令

> 这与严格求值语言中保存调用者上下文的方式类似，但在实际实现中会采用更高效的方法。

```
fn GState::eval(self : GState) -> Unit {
  let addr = self.pop1()
  self.put_dump(self.code, self.stack)
  self.stack = @list.List([addr])
  self.code = @list.List([Unwind])
}
```



这个简单的定义要求我们修改 `Unwind` 指令，使其在遇到 `NNum` 分支时，如果发现存在可恢复的上下文（即 `dump` 不为空），则恢复该上下文。

```
fn GState::unwind(self : GState) -> Unit {
  let addr = self.pop1()
  match self.heap[addr] {
    NNum(_) =>
      match self.dump {
        Empty => self.put_stack(addr)
        More((instrs, stack), tail=rest_dump) => {
          self.stack = stack
          self.put_stack(addr)
          self.dump = rest_dump
          self.code = instrs
        }
      }
    NApp(a1, _) => {
      self.put_stack(addr)
      self.put_stack(a1)
      self.put_code(@list.List([Unwind]))
    }
    NGlobal(_, n, c) =>
      if self.stack.length() < n {
        abort("Unwinding with too few arguments")
      } else {
        if n != 0 {
          self.rearrange(n)
        } else {
          self.put_stack(addr)
        }
        self.put_code(c)
      }
    NInd(a) => {
      self.put_stack(a)
      self.put_code(@list.List([Unwind]))
    }
  }
}
```



接下来，我们需要实现算术和比较算法。我们使用两个函数来简化二进制运算的形式。比较指令的结果是一个布尔值，简单起见我们使用数字来表示它：0 表示 `false`，1 表示 `true`。

```
fn GState::negate(self : GState) -> Unit {
  let addr = self.pop1()
  match self.heap[addr] {
    NNum(n) => {
      let addr = self.heap.alloc(NNum(-n))
      self.put_stack(addr)
    }
    otherwise =>
      abort(
        "negate: wrong kind of node \{@debug.to_string(otherwise)}, address \{@debug.to_string(addr)}",
      )
  }
}

fn GState::lift_arith2(self : GState, op : (Int32, Int32) -> Int32) -> Unit {
  let (a1, a2) = self.pop2()
  match (self.heap[a1], self.heap[a2]) {
    (NNum(n1), NNum(n2)) => {
      let newnode = Node::NNum(op(n1, n2))
      let addr = self.heap.alloc(newnode)
      self.put_stack(addr)
    }
    (node1, node2) =>
      abort(
        "liftArith2: \{@debug.to_string(a1)} = \{@debug.to_string(node1)} \{@debug.to_string(a2)} = \{@debug.to_string(node2)}",
      )
  }
}

fn GState::lift_cmp2(self : GState, op : (Int32, Int32) -> Bool) -> Unit {
  let (a1, a2) = self.pop2()
  match (self.heap[a1], self.heap[a2]) {
    (NNum(n1), NNum(n2)) => {
      let flag = op(n1, n2)
      let newnode = if flag { Node::NNum(1) } else { Node::NNum(0) }
      let addr = self.heap.alloc(newnode)
      self.put_stack(addr)
    }
    (node1, node2) =>
      abort(
        "liftCmp2: \{@debug.to_string(a1)} = \{@debug.to_string(node1)} \{@debug.to_string(a2)} = \{@debug.to_string(node2)}",
      )
  }
}
```



最后，实现分支：

```
fn GState::condition(
  self : GState,
  i1 : List[Instruction],
  i2 : List[Instruction],
) -> Unit {
  let addr = self.pop1()
  match self.heap[addr] {
    NNum(0) =>
      // false
      self.code = i2 + self.code
    NNum(1) =>
      // true
      self.code = i1 + self.code
    otherwise =>
      abort("cond : \{@debug.to_string(addr)} = \{@debug.to_string(otherwise)}")
  }
}
```



编译部分不需要进行重大调整，只需添加一些预定义程序：

```
let compiled_primitives : List[(String, Int32, List[Instruction])] = @list.List([
    // Arith
    (
      "add",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Add,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "sub",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Sub,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "mul",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Mul,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "div",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Div,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    // Compare
    (
      "eq",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Eq,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "neq",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Ne,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "ge",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Ge,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "gt",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Gt,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "le",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Le,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "lt",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Lt,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    // MISC
    (
      "negate",
      1,
      @list.List([Push(0), Eval, Neg, Update(1), Pop(1), Unwind]),
    ),
    (
      "if",
      3,
      @list.List([
        Push(0),
        Eval,
        Cond(@list.List([Push(1)]), @list.List([Push(2)])),
        Update(3),
        Pop(3),
        Unwind,
      ]),
    ),
  ],
)
```



并修改初始指令序列

```
let initialState : GState = {
  heap,
  stack: @list.List([]),
  code: @list.List([PushGlobal("main"), Eval]),
  globals,
  stats: 0,
  dump: @list.List([]),
}
```



## 总结

在下一章，我们将改进原语的代码生成，并添加对数据结构的支持。

# G-Machine 第三部分

本文是关于在 MoonBit 中实现 Haskell 懒惰求值的系列文章中的第三篇。在上一篇文章中，我们学习了如何编译 `let` 表达式以及如何实现基本的算术和比较操作。在本文中，我们将实现一种基于上下文的优化方法，并添加对数据结构的支持。

## 追踪上下文

让我们回顾一下我们在 [上一篇教程](https://docs.moonbitlang.cn/example/gmachine/gmachine-2.html) 中如何实现原语的。

```
let compiled_primitives : List[(String, Int32, List[Instruction])] = @list.List([
    // Arith
    (
      "add",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Add,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "sub",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Sub,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "mul",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Mul,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "div",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Div,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    // Compare
    (
      "eq",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Eq,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "neq",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Ne,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "ge",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Ge,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "gt",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Gt,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "le",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Le,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    (
      "lt",
      2,
      @list.List([
        Push(1),
        Eval,
        Push(1),
        Eval,
        Lt,
        Update(2),
        Pop(2),
        Unwind,
      ]),
    ),
    // MISC
    (
      "negate",
      1,
      @list.List([Push(0), Eval, Neg, Update(1), Pop(1), Unwind]),
    ),
    (
      "if",
      3,
      @list.List([
        Push(0),
        Eval,
        Cond(@list.List([Push(1)]), @list.List([Push(2)])),
        Update(3),
        Pop(3),
        Unwind,
      ]),
    ),
  ],
)
```



这个实现引入了许多 `Eval` 指令，但它们并不总是必要的。例如：

```
(add 3 (mul 4 5))
```



add`的两个参数在执行`Eval`之前已经处于 WHNF（弱头正常形式），因此，这里的`Eval` 指令是多余的。

一种可行的优化方法是在编译表达式时考虑上下文。例如，`add` 需要其参数被求值到 WHNF，因此它的参数在编译过程中处于严格上下文。通过这种方式，我们可以识别出一些可以安全地使用严格求值编译的表达式（仅为其中的一部分）。

- 超级组合子定义中的表达式处于严格上下文中。
- 如果 `(op e1 e2)` 处于严格上下文中（其中 `op` 是一个原语），那么 `e1` 和 `e2` 也处于严格上下文中。
- 如果 `(let (.....) e)` 处于严格上下文中，那么 `e` 也处于严格上下文中（但与局部变量对应的表达式不一定是严格的，因为 `e` 可能不需要它们的结果）。

我们使用 `compileE` 函数在严格上下文中实现编译，确保_栈顶的值始终处于 WHNF_。

对于默认分支，我们仅在 `compileC` 的结果后添加一个 `Eval` 指令。

```
_ => self.compileC(env) + @list.List([Eval])
```



常量被直接推入。

```
Num(n) => @list.List([PushInt(n)])
```



对于 `let/letrec` 表达式，专门设计的 `compileLet` 和 `compileLetrec` 变得非常有用。在严格上下文中编译 `let/letrec` 表达式时，只需要使用 `compileE` 来编译它的主要表达式。

```
Let(rec, defs, e) =>
  if rec {
    compileLetrec(RawExpr::compileE, defs, e, env)
  } else {
    compileLet(RawExpr::compileE, defs, e, env)
  }
```



`if` 和 `negate` 函数分别需要 3 和 1 个参数，需要特殊处理。

```
App(App(App(Var("if"), b), e1), e2) => {
  let condition = b.compileE(env)
  let branch1 = e1.compileE(env)
  let branch2 = e2.compileE(env)
  condition + @list.List([Cond(branch1, branch2)])
}
App(Var("negate"), e) => e.compileE(env) + @list.List([Neg])
```



基本的二元操作可以通过查找表统一处理。首先，构建一个名为 `builtinOpS` 的哈希表，通过原语的名称查询相应的指令。

```
let builtinOpS : @hashmap.HashMap[String, Instruction] = {
  let table = @hashmap.HashMap([], capacity=50)
  table["add"] = Add
  table["mul"] = Mul
  table["sub"] = Sub
  table["div"] = Div
  table["eq"] = Eq
  table["neq"] = Ne
  table["ge"] = Ge
  table["gt"] = Gt
  table["le"] = Le
  table["lt"] = Lt
  table
}
```



其余的处理没有太大区别。

```
App(App(Var(op), e0), e1) =>
  match builtinOpS.get(op) {
    None => self.compileC(env) + @list.List([Eval])
    Some(instr) => {
      let code1 = e1.compileE(env)
      let code0 = e0.compileE(argOffset(1, env))
      code1 + code0 + @list.List([instr])
    }
  }
```



我们完成了吗？看起来是的，但除了整数之外，还有另一种 WHNF：部分应用函数。

部分应用是指参数数量不足的情况。这种情况在高阶函数中很常见，例如：

```
(map (add 1) listofnumbers)
```



这里，`(add 1)` 是一个部分应用。

为了确保新编译策略生成的代码正常工作，我们需要修改 `NGlobal` 分支的 `Unwind` 指令实现。当参数不足且转储保存了堆栈时，我们应仅保留原始的红 ex 并恢复堆栈。

```
NGlobal(_, n, c) => {
  let k = self.stack.length()
  if k < n {
    match self.dump {
      Empty => abort("Unwinding with too few arguments")
      More((i, s), tail=rest) => {
        // a1 : ...... : ak
        // ||
        // ak : s
        self.stack = self.stack.drop(k - 1) + s
        self.dump = rest
        self.code = i
      }
    }
  } else {
    if n != 0 {
      self.rearrange(n)
    } else {
      self.put_stack(addr)
    }
    self.put_code(c)
  }
}
```



这种基于上下文的严格性分析技术很有用，但不能处理超级组合子调用。在这里，我们简要介绍一种基于布尔运算的严格性分析技术，它可以分析超级组合子调用的哪些参数应该使用严格模式编译。

我们首先定义一个概念：bottom，它在概念上代表一个永不终止或引发异常的值。对于一个超级组合子 `f a[1] ...... a[n]`，如果其中一个参数 `a[i]` 满足 `a[i] = bottom`，那么 `f a[1] .... a[i] .... a[n] = bottom`（其他参数不是 bottom）。这表明，无论 `f` 的内部控制流多么复杂，它**必须**需要参数 `a[i]` 的结果才能得到最终结果。因此，`a[i]` 应该被严格求值。

> 如果此条件不满足，并不一定意味着该参数完全不需要；它可能只在某些分支中使用，其使用在运行时确定。这样的参数是应该延迟求值的典型例子。

我们将 bottom 视为 `false`，非 bottom 值视为 `true`。这样，coreF 中的所有函数都可以视为布尔函数。以 `abs` 为例：

```
(defn abs[n]
  (if (lt n 0) (negate n) n))
```



我们分析如何将其从上到下转换为布尔函数：

- 对于像 `(if x y z)` 这样的表达式，`x` 必须被求值，但只需要评估 `y` 或 `z` 之一。这可以转换为 `x and (y or z)`。以上面的函数为例，如果 `n` 是 bottom，那么条件 `(lt n 0)` 也是 bottom，因此整个表达式的结果也是 bottom。
- 对于原始表达式，使用 `and` 连接所有部分即可。

为了确定一个参数是否需要严格编译，可以将上述条件转换为布尔函数：`a[i] = false` 表示 `f a[1] .... a[i] .... a[n] = false`（其他所有参数为 true）。

> 这本质上是一种名为“抽象解释”的程序分析方法。

## 自定义数据结构

Haskell 中的数据结构类型定义类似于 MoonBit 中的 `enum`。然而，由于 CoreF 是一种简单的玩具语言，用于演示懒惰求值，它不允许自定义数据类型。唯一的内置数据结构是懒惰列表。

```
(defn take[n l]
  (case l
    [(Nil) Nil]
    [(Cons x xs)
      (if (le n 0)
        Nil
        (Cons x (take (sub n 1) xs)))]))
```



如上所示，可以使用 `case` 表达式进行列表的简单模式匹配。

列表的对应图节点是 `NConstr(Int32, List[Addr])`，由两部分组成：

- 不同值构造器的标签：`Nil` 的标签是 0，`Cons` 的标签是 1。
- 用于存储子结构的地址列表，其长度对应于值构造器的参数数量（元数）。

> 该图节点结构可用于实现各种数据结构，但 CoreF 没有类型系统。为了演示目的，仅实现了懒惰列表。

我们需要添加两个指令，`Split` 和 `Pack`，来解构和构建列表。

```
fn GState::pack(self : GState, t : Int32, n : Int32) -> Unit {
  let addrs = self.stack.take(n)
  self.stack = self.stack.drop(n)
  let addr = self.heap.alloc(NConstr(t, addrs))
  self.put_stack(addr)
}

fn GState::split(self : GState) -> Unit {
  let addr = self.pop1()
  match self.heap[addr] {
    NConstr(_, addrs) =>
      // n == addrs.length()
      self.stack = addrs + self.stack
    _ => panic()
  }
}
```



此外，需要一个 `CaseJump` 指令来实现 `case` 表达式。

```
fn GState::casejump(
  self : GState,
  table : List[(Int32, List[Instruction])],
) -> Unit {
  let addr = self.pop1()
  match self.heap[addr] {
    NConstr(t, _) =>
      match table.lookup(t) {
        None => abort("casejump")
        Some(instrs) => {
          self.code = instrs + self.code
          self.put_stack(addr)
        }
      }
    otherwise =>
      abort(
        "casejump(): addr = \{@debug.to_string(addr)} node = \{@debug.to_string(otherwise)}",
      )
  }
}
```



在添加上述指令之后，我们需要修改 `compileC` 和 `compileE` 函数。由于 `case` 表达式匹配的对象需要被求值到 WHNF，因此只能通过 `compileE` 函数来编译它。

```
App(App(Constructor(tag=1, arity=2), x), xs) =>
  // Cons(x, xs)
  xs.compileC(env) +
  x.compileC(argOffset(1, env)) +
  @list.List([Pack(1, 2)])
// Empty
Constructor(tag=0, arity=0) => @list.List([Pack(0, 0)])
```



```
Case(e, alts) =>
  e.compileE(env) + @list.List([CaseJump(compileAlts(alts, env))])
Constructor(tag=0, arity=0) =>
  // Empty
  @list.List([Pack(0, 0)])
App(App(Constructor(tag=1, arity=2), x), xs) =>
  // Cons(x, xs)
  xs.compileC(env) +
  x.compileC(argOffset(1, env)) +
  @list.List([Pack(1, 2)])
```



此时，出现了一个新问题。以前，打印求值结果只需要处理简单的 `NNum` 节点，但 `NConstr` 节点有子结构。当列表本身被求值到 WHNF 时，它的子结构大多是未求值的 `NApp` 节点。我们需要添加一个 `Print` 指令，它将递归地求值并将结果写入 `GState` 的 `output` 组件。

```
fn GState::gprint(self : GState) -> Unit {
  let addr = self.pop1()
  match self.heap[addr] {
    NNum(n) => {
      self.output.write_string(n.to_string())
      self.output.write_char(' ')
    }
    NConstr(0, Empty) => self.output.write_string("Nil")
    NConstr(1, More(addr1, tail=More(addr2, tail=Empty))) => {
      self.code = @list.List([Instruction::Eval, Print, Eval, Print]) +
        self.code
      self.put_stack(addr2)
      self.put_stack(addr1)
    }
    _ => panic()
  }
}
```



最后，将 G-Machine 的初始代码修改为：

```
let initialState : GState = {
  output: StringBuilder(size_hint=60),
  heap,
  stack: @list.List([]),
  code: @list.List([PushGlobal("main"), Eval, Print]),
  globals,
  stats: 0,
  dump: @list.List([]),
}
```



现在，我们可以使用懒惰列表编写一些经典的函数式程序，例如无限斐波那契数列：

```
(defn fibs[] (Cons 0 (Cons 1 (zipWith add fibs (tail fibs)))))
```



引入数据结构后，严格性分析变得更加复杂。对于懒惰列表，有几种评估模式：

- 完全严格（要求列表是有限的，且所有元素都不能是底值）。
- 完全懒惰。
- 头部严格（列表可以是无限的，但其元素不能是底值）。
- 尾部严格（列表必须是有限的，但其元素可以是底值）。

此外，函数使用的上下文可以改变其参数的评估模式（不能孤立分析，需要跨函数分析）。这种复杂的严格性分析通常采用投影分析技术。相关文献包括：

- Projections for Strictness Analysis
- Static Analysis and Code Optimizations in Glasgow Haskell Compiler
- Implementing Projection-based Strictness Analysis
- Theory and Practice of Demand Analysis in Haskell

## 结语

懒惰求值可以减少运行时冗余计算，但它也引入了一些新问题，例如：

- 臭名昭著的副作用顺序问题。
- 过多的冗余节点。一些未共享的计算仍然将结果存储在堆中，这不利于利用 CPU 的缓存机制。

懒惰求值语言的代表 Haskell 提出了一个有争议的解决方案来解决副作用顺序问题：单子（Monads）。这个解决方案对急切求值语言也有一定价值，但许多在线教程过于强调其数学背景，未能有效解释如何使用它。

Idris2，Haskell 的继任者（不再是懒惰语言），保留了单子并引入了另一种处理副作用的机制：代数效应（Algebraic Effects）。

由 SPJ 设计的无脊柱 G-Machine 改善了过多冗余节点的问题，它的继任者 STG 统一了不同类型节点的数据布局。

除了抽象机器模型的改进外，GHC 对 Haskell 程序的优化还大量依赖于基于内联的优化和基于投影分析的严格性分析技术。

2004 年，几位 GHC 设计者发现，之前的 push-enter 模型（参数被推入栈中，然后调用函数）比 eval-apply 模型效果差，后者将责任交给了调用者。他们发表了一篇题为《Making a Fast Curry: Push/Enter vs. Eval/Apply for Higher-order Languages》的论文。

2007 年，Simon Marlow 发现 tagless 设计中的跳转和执行代码显著影响了现代 CPU 分支预测器的性能。论文《Faster laziness using dynamic pointer tagging》描述了几种解决方案。

懒惰的纯函数式语言展现了许多有趣的可能性，但也面临着许多批评和反思。尽管如此，它无疑是一项引人入胜的技术！

# Myers Diff

目录：

- Myers diff

  - [“差异”的定义及其度量标准](https://docs.moonbitlang.cn/example/myers-diff/myers-diff.html#defining-difference-and-its-measurement-criteria)
  - [算法概述](https://docs.moonbitlang.cn/example/myers-diff/myers-diff.html#algorithm-overview)
  - [实现](https://docs.moonbitlang.cn/example/myers-diff/myers-diff.html#implementation)
  - [结语](https://docs.moonbitlang.cn/example/myers-diff/myers-diff.html#epilogue)

- Myers diff 2

  - [记录搜索过程](https://docs.moonbitlang.cn/example/myers-diff/myers-diff2.html#recording-the-search-process)
  - [回溯编辑路径](https://docs.moonbitlang.cn/example/myers-diff/myers-diff2.html#backtracking-the-edit-path)
  - [打印 diff](https://docs.moonbitlang.cn/example/myers-diff/myers-diff2.html#printing-the-diff)
  - [总结](https://docs.moonbitlang.cn/example/myers-diff/myers-diff2.html#conclusion)

- Myers diff 3

  - [分而治之](https://docs.moonbitlang.cn/example/myers-diff/myers-diff3.html#divide-and-conquer)

  - [总结](https://docs.moonbitlang.cn/example/myers-diff/myers-diff3.html#conclusion)

    

# Myers diff

你是否曾经使用过 Unix 系统中的 'diff' 工具？简单来说，它是一种用于比较两个文本文件之间差异的工具。此外，Unix 系统中还有名为 'patch' 的工具。

现在很少有人手动应用软件包的修补，但 'diff' 在另一个领域中仍然非常有用：版本控制系统。你有看到特定提交后代码文件所做更改（并以不同的颜色突出显示）的函数是非常方便的。例如，最受欢迎的版本控制系统之一，git，就是一个很好的例子。

```
diff --git a/main/main.mbt b/main/main.mbt
index 99f4c4c..52b1388 100644
--- a/main/main.mbt
+++ b/main/main.mbt
@@ -3,7 +3,7 @@

 fn main {
   let a = lines("A\nB\nC\nA\nB\nB\nA")
-  let b = lines("C\nB\nA\nB\nA\nC")
+  let b = lines("C\nB\nA\nB\nA\nA")
   let r = shortst_edit(a, b)
   println(r)
 }
```



但我们具体怎么计算两个文本文件之间的差异呢？

Git 的默认比较差异算法由 Eugene W. Myers 在他的论文**一个 O(ND) 的差分算法及其变体**中提出。这篇论文主要聚焦于证明该算法的正确性。接下来，我们将以一种不那么严谨的方式理解其基本架构，并使用 MoonBit 编写一个简单的实现。

## “差异”的定义及其度量标准

当我们讨论两个文本文件之间的“差异”时，我们实际上是在指能将文本 a 变成文本 b 的一系列编辑步骤。

假设文本 a 的内容是

```
A
B
C
A
B
B
A
```



假设文本 b 的内容是

```
C
B
A
B
A
C
```



为了把文本 a 转变为文本 b，最简单的编辑序列是删除所有 a 中的字符（用减号表示），然后插入文本 b 中的每个字符（用加号表示）。

```
- A
- B
- C
- A
- B
- B
- A
+ C
+ B
+ A
+ B
+ A
+ C
```



但是这样的结果可能对程序员阅读程序来说并没有太大帮助。接下来的编辑序列会好很多，至少它更短。

```
- A
- B
  C
+ B
  A
  B
- B
  A
+ C
```



实际上，这是实现文本 a 转换为文本 b 所需的最简编辑序列，仅需要 5 个操作。如果我们只考虑编辑序列的长度，这一结果已经令人满意。但在探索多种编程语言时，我们发现除了编辑序列长度外，还有其他度量指标对用户体验同样重要。让我们来看看以下例子：

```
// good quality
  struct RHSet[T] {
    set : RHTable[T, Unit]
  }
+
+ fn[T] RHSet::new(capacity : Int32) -> RHSet[T] {
+  let set : RHTable[T, Unit]= RHTable::new(capacity)
+  { set : set }
+ }


// bad quality
  struct RHSet[T] {
    set : RHTable[T, Unit]
+ }
+
+ fn[T] RHSet::new(capacity : Int32) -> RHSet[T] {
+  let set : RHTable[T, Unit]= RHTable::new(capacity)
+  { set : set }
  }
```



当我们在文件末尾插入一个新函数定义时，理想的编辑序列应将所做的更改置于文件末尾。同样，在有删除和插入操作的情况下，不应该将这两个操作交替进行计算。这是另一个例子。

```
Good:   - one         Bad:    - one
        - two                 + four
        - three               - two
        + four                + five
        + five                + six
        + six                 - three
```



Myers 的 diff 算法可以满足所有这些需求。它是一种贪婪算法，每次都尽可能地跳过匹配行（避免在出现'{'之前插入文本），同时也会尝试将删除操作置于插入操作之前，避免后者发生。

## 算法概述

Myers 的论文中的基本思路是构建一个编辑操作的网格图，并在该网格上搜索最短路径。以之前的例子 'a = ABCABBA' 和 'b = CBABAC' 为例，我们创建一个 '(x, y)' 坐标网格。

```
    0     1     2     3     4     5     6     7

0   o-----o-----o-----o-----o-----o-----o-----o
    |     |     | \   |     |     |     |     |
    |     |     |  \  |     |     |     |     |   C
    |     |     |   \ |     |     |     |     |
1   o-----o-----o-----o-----o-----o-----o-----o
    |     | \   |     |     | \   | \   |     |
    |     |  \  |     |     |  \  |  \  |     |   B
    |     |   \ |     |     |   \ |   \ |     |
2   o-----o-----o-----o-----o-----o-----o-----o
    | \   |     |     | \   |     |     | \   |
    |  \  |     |     |  \  |     |     |  \  |   A
    |   \ |     |     |   \ |     |     |   \ |
3   o-----o-----o-----o-----o-----o-----o-----o
    |     | \   |     |     | \   | \   |     |
    |     |  \  |     |     |  \  |  \  |     |   B
    |     |   \ |     |     |   \ |   \ |     |
4   o-----o-----o-----o-----o-----o-----o-----o
    | \   |     |     | \   |     |     | \   |
    |  \  |     |     |  \  |     |     |  \  |   A
    |   \ |     |     |   \ |     |     |   \ |
5   o-----o-----o-----o-----o-----o-----o-----o
    |     |     | \   |     |     |     |     |
    |     |     |  \  |     |     |     |     |   C
    |     |     |   \ |     |     |     |     |
6   o-----o-----o-----o-----o-----o-----o-----o


       A     B     C     A     B     B     A
```



该网格的左上角是起始点 '(0, 0)'，右下角是终点 '(7, 6)'。沿着 x 轴移动一个单位右侧删除 a 中的对应字符，沿 y 轴向下移动一个单位插入 b 中的对应字符。斜线表示匹配字符，可跳过而不触发编辑。

在编写实际搜索代码之前，我们手动执行两轮搜索。

- 第一轮从 '(0, 0)' 开始，移动一步到达 '(0,1)' 和 '(1,0)'。
- 第二轮从 '(0,1)' 和 '(1, 0)' 开始。从 '(0,1)' 向下移动到 '(0,2)'，但有一条斜线指向 '(1,3)'，因此最终点是 '(1,3)'。

Myers 算法的整个原理基于这种广度优先搜索。

## 实现

我们已经概述了基本思想，现在是详细考虑设计的时候了。算法的输入是两个字符串，但是搜索需要在一个图上进行。而构造图然后再去搜索它是浪费内存和时间成本的。

Myers 算法的实现采用了一种聪明的方法，定义了一个新的坐标 `k = x - y`。

- 向右移动会使 `k` 增加 1。
- 向左移动会使 `k` 减少 1
- 沿对角线向左下方移动保持 `k` 不变

让我们定义另一个坐标 `d` 来表示搜索的深度。以 `d` 为横轴，`k` 为纵轴，我们可以画出搜索过程的树状图。

```
    |      0     1     2     3     4     5
----+--------------------------------------
    |
 4  |                             7,3
    |                           /
 3  |                       5,2
    |                     /
 2  |                 3,1         7,5
    |               /     \     /     \
 1  |           1,0         5,4         7,6
    |         /     \           \
 0  |     0,0         2,2         5,5
    |         \                       \
-1  |           0,1         4,5         5,6
    |               \     /     \
-2  |                 2,4         4,6
    |                     \
-3  |                       3,6
```



你可以看到，在每一轮搜索中，`k` 严格地在 `[-d, d]` 范围内（因为在一次移动中，它最多可以比前一轮增加或减少 1），并且点之间的 `k` 值的间隔为 2。Myers 算法的基本思想来自于这样一个思想：通过遍历 `d` 和 `k` 来进行搜索。当然，它还需要保存每一轮的 `x` 坐标，以便在下一轮搜索中使用。

让我们首先定义 `Line` 结构，它代表文本中的一行。

```
struct Line {
  number : Int32 // Line number
  text : String // Does not include newline
} derive(ToJson)

///|
pub extend Line with ToJson::{to_json}

///|
fn Line::new(number : Int32, text : String) -> Line {
  Line::{ number, text }
}
```



然后，定义一个辅助函数，根据换行符将字符串拆分为 `Array[Line]`。注意，行号从 1 开始。

```
fn lines(str : String) -> Array[Line] {
  let lines = Array(capacity=50)
  let mut line_number = 0
  for line in str.split("\n") {
    line_number = line_number + 1
    lines.push(Line::new(line_number, line.to_owned()))
  } nobreak {
    return lines
  }
}
```



接下来，我们需要包装数组，以便它支持负索引，因为我们将使用 `k` 的值作为索引。

```
///
struct BPArray[T](Array[T]) // BiPolar Array

///|
fn[T] BPArray::make(capacity : Int32, default : T) -> BPArray[T] {
  let arr = Array::make(capacity, default)
  BPArray(arr)
}

///|
fn[T] BPArray::copy(self : BPArray[T]) -> BPArray[T] {
  let BPArray(arr) = self
  BPArray(arr.copy())
}

///|
#alias("_[_]")
fn[T] BPArray::get(self : BPArray[T], idx : Int32) -> T {
  let BPArray(arr) = self
  if idx < 0 {
    arr[arr.length() + idx]
  } else {
    arr[idx]
  }
}

///|
#alias("_[_]=_")
fn[T] BPArray::set(self : BPArray[T], idx : Int32, elem : T) -> Unit {
  let BPArray(arr) = self
  if idx < 0 {
    arr[arr.length() + idx] = elem
  } else {
    arr[idx] = elem
  }
}
```



现在我们可以开始编写搜索函数了。在搜索完整路径之前，让我们从第一个目标开始，即找到最短路径的长度（等于搜索深度）。以下是基本框架：

```
fn shortest_edit(old~ : Array[Line], new~ : Array[Line]) -> Int32 {
  let n = old.length()
  let m = new.length()
  let max = n + m
  let v = BPArray::make(2 * max + 1, 0)
  for d = 0; d < max + 1; d = d + 1 {
    for k = -d; k < d + 1; k = k + 2 {
    ......
    }
  }
}
```



在最极端的情况下（两个文本没有匹配的行），可以推断所需的最大步数为 `n + m`，最小步数为 0。因此，设置变量 `max = n + m`。数组 `v` 使用 `k` 作为索引来存储 `x` 值的历史记录。因为 `k` 的范围是从 `[-d, d]`，所以这个数组的大小被设置为 `2 * max + 1`。

但即使在这一点上，仍然很难弄清楚下一步该怎么做，所以我们只考虑 `d = 0; k = 0` 的情况，在这一点，它一定在 `(0, 0)` 处。此外，如果两篇文本的开头相同，可以直接跳过。我们将这一轮的最终坐标写入数组 `v`。

```
if d == 0 { // When d equals 0, k must also equal 0
  x = 0
  y = x - k
  while x < n && y < m && old[x].text == new[y].text {
    // Skip all matching lines
    x = x + 1
    y = y + 1
  }
  v[k] = x
}
```



当 `d > 0` 时，需要前一轮存储的坐标信息。当我们知道一个点的 `k` 值和前一轮搜索中点的坐标时，就很容易推导出 `v[k]` 的值。因为每一步 k 只能增加或减少 1，所以搜索树中的 `v[k]` 必须从 `v[k - 1]` 或`v[k + 1]` 扩展。而下一个问题是：如何在以 `v[k - 1]` 和 `v[k + 1]` 结尾的两条路径之间做出选择？

有两种边界情况:`k == -d` 和 `k == d`。

- 当 `k == -d` 时，只能选择 `v[k + 1]`。
- 当 `k == d` 时，只能选择 `v[k - 1]`。

而回顾前面提到的要求：尽可能在插入之前删除，这本质上意味着从前一个位置选择具有最大 `x` 值的位置。

```
if k == -d {
  x = v[k + 1]
} else if k == d {
  x = v[k - 1] + 1 // add 1 to move horizontally
} else if v[k - 1] < v[k + 1] {
  x = v[k + 1]
} else {
  x = v[k - 1] + 1
}
```



合并这四个分支，我们得到以下代码：

```
if k == -d || (k != d && v[k - 1] < v[k + 1]) {
  x = v[k + 1]
} else {
  x = v[k - 1] + 1
}
```



结合上述所有步骤，我们得到以下代码：

```
///
fn shortest_edit(old~ : Array[Line], new~ : Array[Line]) -> Int32 {
  let n = old.length()
  let m = new.length()
  let max = n + m
  let v = BPArray::make(2 * max + 1, 0)
  // v[1] = 0
  for d = 0; d < max + 1; d = d + 1 {
    for k = -d; k < d + 1; k = k + 2 {
      let mut x = 0
      let mut y = 0
      // if d == 0 {
      //   x = 0
      // }
      if k == -d || (k != d && v[k - 1] < v[k + 1]) {
        x = v[k + 1]
      } else {
        x = v[k - 1] + 1
      }
      y = x - k
      while x < n && y < m && old[x].text == new[y].text {
        // Skip all matching lines
        x = x + 1
        y = y + 1
      }
      v[k] = x
      if x >= n && y >= m {
        return d
      }
    }
  } nobreak {
    abort("impossible")
  }
}
```



由于数组的初始值为 0，我们可以省略 `d == 0` 的分支。

## 结语

我们已经实现了 Myers 算法的一个不完整版本，它完成了正向路径搜索。在下一篇文章中，我们将实现回溯以恢复完整的编辑路径，并编写一个函数来输出彩色差值。

本文引用：

- [The Myers diff algorithm](https://blog.jcoglan.com/2017/02/15/the-myers-diff-algorithm-part-2/)

感谢作者 James Coglan。

# Myers diff 2

这是 diff 系列的第二篇文章。在上一篇 [myers-diff](https://docs.moonbitlang.cn/example/myers-diff/myers-diff.html) 中，我们学习了如何将计算差分的过程转化为图搜索问题，以及如何搜索最短的编辑距离。在本文中，我们将学习如何扩展前一篇文章中的搜索过程，以获得完整的编辑序列。

## 记录搜索过程

获得完整编辑序列的第一步是保存整个编辑过程。这一步相对简单：我们只需要保存当前搜索深度 `d` 和每个搜索轮开始时深度 `d` 的图节点。

```
///
fn shortest_edit(
  old~ : Array[Line],
  new~ : Array[Line],
) -> Array[(BPArray[Int32], Int32)] {
  let n = old.length()
  let m = new.length()
  let max = n + m
  let v = BPArray::make(2 * max + 1, 0)
  let trace = []
  fn push(v : BPArray[Int32], d : Int32) -> Unit {
    trace.push((v, d))
  }
  // v[1] = 0
  for d = 0; d < max + 1; d = d + 1 {
    push(v.copy(), d)
    for k = -d; k < d + 1; k = k + 2 {
      let mut x = 0
      let mut y = 0
      // if d == 0 {
      //   x = 0
      // }
      if k == -d || (k != d && v[k - 1] < v[k + 1]) {
        x = v[k + 1]
      } else {
        x = v[k - 1] + 1
      }
      y = x - k
      while x < n && y < m && old[x].text == new[y].text {
        x = x + 1
        y = y + 1
      }
      v[k] = x
      if x >= n && y >= m {
        return trace
      }
    }
  } nobreak {
    abort("impossible")
  }
}
```



## 回溯编辑路径

在记录了整个搜索过程之后，下一步是从端点返回以查找所使用的路径。但在我们这样做之前，让我们先定义 `Edit` 类型。

```
///
enum Edit {
  Insert(new~ : Line)
  Delete(old~ : Line)
  Equal(old~ : Line, new~ : Line) // old, new
}
```



接下来，让我们执行回溯。

```
///
fn backtrack(
  new~ : Array[Line],
  old~ : Array[Line],
  trace : Array[(BPArray[Int32], Int32)],
) -> Array[Edit] {
  let mut x = old.length()
  let mut y = new.length()
  let edits = Array(capacity=trace.length())
```



回溯的方法本质上与正向搜索相同，只是方向相反。

- 使用 `x` 和 `y` 计算当前 `k` 值。
- 访问历史记录并使用与前向搜索相同的判断标准来查找前一轮搜索中的 `k` 值。
- 恢复上一轮搜索的坐标。
- 尝试自由移动并记录相应的编辑动作。
- 确定导致 `k` 值更改的编辑类型。
- 继续迭代。

```
for i = trace.length() - 1; i >= 0; i = i - 1 {
  let (v, d) = trace[i]
  let k = x - y
  let prev_k = if k == -d || (k != d && v[k - 1] < v[k + 1]) {
    k + 1
  } else {
    k - 1
  }
  let prev_x = v[prev_k]
  let prev_y = prev_x - prev_k
  while x > prev_x && y > prev_y {
    x = x - 1
    y = y - 1
    edits.push(Equal(old=old[x], new=new[y]))
  }
  if d > 0 {
    if x == prev_x {
      edits.push(Insert(new=new[prev_y]))
    } else if y == prev_y {
      edits.push(Delete(old=old[prev_x]))
    }
    x = prev_x
    y = prev_y
  }
}
```



结合这两个函数，我们得到了一个完整的 `diff` 实现。

```
///
fn diff(old~ : Array[Line], new~ : Array[Line]) -> Array[Edit] {
  let trace = shortest_edit(old~, new~)
  backtrack(old~, new~, trace)
}
```



## 打印 diff

要打印整齐的 diff，我们需要左对齐文本。另外，由于回溯过程中的顺序问题，我们需要从后往前打印。

```
///
let line_width = 4

///|
fn pad_right(s : String, width : Int32) -> String {
  String::make(width - s.length(), ' ') + s
}

///|
fn pprint_edit(edit : Edit) -> String {
  match edit {
    Insert(_) as edit => {
      let tag = "+"
      let old_line = pad_right("", line_width)
      let new_line = pad_right(edit.new.number.to_string(), line_width)
      let text = edit.new.text
      "\{tag} \{old_line} \{new_line}    \{text}"
    }
    Delete(_) as edit => {
      let tag = "-"
      let old_line = pad_right(edit.old.number.to_string(), line_width)
      let new_line = pad_right("", line_width)
      let text = edit.old.text
      "\{tag} \{old_line} \{new_line}    \{text}"
    }
    Equal(_) as edit => {
      let tag = " "
      let old_line = pad_right(edit.old.number.to_string(), line_width)
      let new_line = pad_right(edit.new.number.to_string(), line_width)
      let text = edit.old.text
      "\{tag} \{old_line} \{new_line}    \{text}"
    }
  }
}

///|
fn pprint_diff(diff : Array[Edit]) -> String {
  let buf = StringBuilder(size_hint=100)
  for i = diff.length(); i > 0; i = i - 1 {
    buf.write_string(pprint_edit(diff[i - 1]))
    buf.write_char('\n')
  } nobreak {
    buf.to_string()
  }
}
```



结果如下：

```
-    1         A
-    2         B
     3    1    C
+         2    B
     4    3    A
     5    4    B
-    6         B
     7    5    A
+         6    C
```



## 总结

上面演示的 Myers 算法是完整的，但是由于频繁地复制数组，它有非常大的空间开销。因此，像 Git 这样的大多数软件使用 diff 算法的线性变体（在原始论文的附录中找到）。这种变体有时可能会产生比标准 Myers 算法质量更低的 diffs（对人类来说更难阅读），但仍然可以确保最短的编辑序列。

# Myers diff 3

本文是 [diff 系列](https://docs.moonbitlang.cn/example/myers-diff/index.html) 的第三篇。在 [上一部分](https://docs.moonbitlang.cn/example/myers-diff/myers-diff2.html) 中，我们探讨了完整的 Myers 算法及其局限性。在这篇文章中，我们将学习如何实现 Myers 算法的一种变体，该算法具有线性空间复杂度。

## 分而治之

Git 使用的 Myers 的 diff 算法的线性变体采用了一个称为 *Snake*（有时称为 *Middle Snake*）的概念来分解整个搜索过程。编辑图中的 Snake 表示在一次向左或向下移动后的 0 到 N 步的对角线移动。线性 Myers 算法在最优编辑路径上找到中间的 Snake，并用它将整个编辑图分成两部分。随后的步骤将相同的技术应用于结果子图，最终生成完整的编辑路径。

```
    0   1   2   3   4   5   6   7   8   9  10  11  12  13  14
 0  o---o---o---o---o---o---o
    |   |   |   |   |   |   |
 1  o---o---o---o---o---o---o
    |   | \ |   |   |   |   |
 2  o---o---o---o---o---o---o
    |   |   |   |   |   |   |
 3  o---o---o---o---o---o---o
    |   |   |   |   | \ |   |
 4  o---o---o---o---o---o---o
    |   |   |   |   |   |   |
 5  o---o---o---o---o---o---o
                              \
 6                              @
                                  \
 7                                  @---o---o---o---o---o---o
                                        |   |   |   |   |   |
 8                                      o---o---o---o---o---o
                                        | \ |   |   |   |   |
 9                                      o---o---o---o---o---o
                                        |   |   |   |   |   |
10                                      o---o---o---o---o---o
                                        |   |   |   |   |   |
11                                      o---o---o---o---o---o
                                        |   |   | \ |   |   |
12                                      o---o---o---o---o---o
                                        |   |   |   |   |   |
13                                      o---o---o---o---o---o
                                        |   |   |   |   | \ |
14                                      o---o---o---o---o---o
```



> 简要回顾一下：最佳编辑路径是到端点的距离最短的路径（对角线距离为零），并且可以有多个这样的路径。

细心的读者可能已经注意到一个鸡生蛋还是蛋生鸡的问题：为了找到 Snake，你需要一个最优的编辑路径，但是为了获得最优的编辑路径，你似乎需要先运行原始的 Myers 算法。

事实上，线性 Myers 算法背后的思想有些不寻常：它从左上角和右下角替换原始 Myers 算法，但不存储历史。相反，它只是检查两边的搜索是否重叠。当它们这样做时，重叠的部分作为 `Middle Snake` 返回。

这种方法似乎很简单，但仍有一些细节需要解决。

当从右下搜索时，对角线坐标不能再被称为 *k*。我们需要定义一个新的对角线坐标 **c = k - delta** 。这个坐标是 *k* 的镜像，非常适合反向搜索。

```
        x                       k
                                  0     1     2     3
        0     1     2     3         \     \     \     \
  y  0  o-----o-----o-----o           o-----o-----o-----o
        |     |     |     |      -1   |     |     |     | \
        |     |     |     |         \ |     |     |     |   2
     1  o-----o-----o-----o           o-----o-----o-----o
        |     | \   |     |      -2   |     | \   |     | \
        |     |   \ |     |         \ |     |   \ |     |   1
     2  o-----o-----o-----o           o-----o-----o-----o
                                        \     \     \     \
                                        -3    -2    -1      0
                                                              c
```



我们如何确定搜索是否重叠？只需检查正向搜索中对角线上的位置的 *x* 值是否大于反向搜索中的 *x* 值。但是，由于同一对角线的 *k* 和 *c* 坐标不同，因此转换可能有点棘手。

### 代码实现

我们将首先定义 `Snake` 和 `Box` 类型，代表 `middle snake` 和子编辑图（因为它们是方形的，所以我们称之为 `Box`）。

```
///
struct Box {
  left : Int32
  right : Int32
  top : Int32
  bottom : Int32
}

///|
struct Snake {
  start : (Int32, Int32)
  end : (Int32, Int32)
}

///|
fn Box::width(self : Self) -> Int32 {
  self.right - self.left
}

///|
fn Box::height(self : Self) -> Int32 {
  self.bottom - self.top
}

///|
fn Box::size(self : Self) -> Int32 {
  self.width() + self.height()
}

///|
fn Box::delta(self : Self) -> Int32 {
  self.width() - self.height()
}
```



为了避免太早陷入细节，让我们假设我们已经有一个函数：`midpoint : (Box, Array[Line], Array[Line]) -> Snake?` 去找 `middle snake`。然后，我们可以构建函数 `find_path` 来搜索完整的路径。

```
///
fn Box::find_path(
  box : Self,
  old~ : Array[Line],
  new~ : Array[Line],
) -> Iter[(Int32, Int32)]? {
  guard box.midpoint(old~, new~) is Some(snake) else { None }
  let start = snake.start
  let end = snake.end
  let headbox = Box::{
    left: box.left,
    top: box.top,
    right: start.0,
    bottom: start.1,
  }
  let tailbox = Box::{
    left: end.0,
    top: end.1,
    right: box.right,
    bottom: box.bottom,
  }
  let head = headbox.find_path(old~, new~).unwrap_or(Iter::singleton(start))
  let tail = tailbox.find_path(old~, new~).unwrap_or(Iter::singleton(end))
  Some(head.concat(tail))
}
```



`find_path` 的实现很简单，但 `midpoint` 有点复杂：

- 对于大小为 0 的 `Box`，返回 `None`。
- 计算搜索边界。因为向前和向后搜索各占一半的距离，所以除以 2。但是，如果 `Box` 的大小是奇数，则在正向搜索边界上再添加一个。
- 将向前和向后搜索的结果存储在两个数组中。
- 在向前和向后搜索之间交替，如果没有找到结果则返回 `None`。

```
///|
fn Box::midpoint(self : Self, old~ : Array[Line], new~ : Array[Line]) -> Snake? {
  if self.size() == 0 {
    return None
  }
  let max = {
    let half = self.size() / 2
    if is_odd(self.size()) {
      half + 1
    } else {
      half
    }
  }
  let vf = BPArray::make(2 * max + 1, 0)
  vf[1] = self.left
  let vb = BPArray::make(2 * max + 1, 0)
  vb[1] = self.bottom
  for d = 0; d < max + 1; d = d + 1 {
    match self.forward(forward=vf, backward=vb, d, old~, new~) {
      None =>
        match self.backward(forward=vf, backward=vb, d, old~, new~) {
          None => continue
          res => return res
        }
      res => return res
    }
  } nobreak {
    None
  }
}
```



与最初的 Myers 算法相比，向前和向后搜索有一些修改，需要做出解释：

- 因为我们需要返回 `snake`，所以搜索过程必须计算前一个坐标（`px` 代表前一个 x）。
- 搜索现在在 `Box`（不是全局编辑图）中工作，因此从 `x` 计算 `y` 需要转换（反之亦然）。
- 反向搜索最小化 `y` 是一种启发式策略，但最小化 `x` 也是可行的。

```
///|
fn Box::forward(
  self : Self,
  forward~ : BPArray[Int32],
  backward~ : BPArray[Int32],
  depth : Int32,
  old~ : Array[Line],
  new~ : Array[Line],
) -> Snake? {
  for k = depth; k >= -depth; k = k - 2 {
    let c = k - self.delta()
    let mut x = 0
    let mut px = 0
    if k == -depth || (k != depth && forward[k - 1] < forward[k + 1]) {
      x = forward[k + 1]
      px = x
    } else {
      px = forward[k - 1]
      x = px + 1
    }
    let mut y = self.top + (x - self.left) - k
    let py = if depth == 0 || x != px { y } else { y - 1 }
    while x < self.right && y < self.bottom && old[x].text == new[y].text {
      x = x + 1
      y = y + 1
    }
    forward[k] = x
    if is_odd(self.delta()) &&
      (c >= -(depth - 1) && c <= depth - 1) &&
      y >= backward[c] {
      return Some(Snake::{ start: (px, py), end: (x, y) })
    }
  }
  return None
}

///|
fn Box::backward(
  self : Self,
  forward~ : BPArray[Int32],
  backward~ : BPArray[Int32],
  depth : Int32,
  old~ : Array[Line],
  new~ : Array[Line],
) -> Snake? {
  for c = depth; c >= -depth; c = c - 2 {
    let k = c + self.delta()
    let mut y = 0
    let mut py = 0
    if c == -depth || (c != depth && backward[c - 1] > backward[c + 1]) {
      y = backward[c + 1]
      py = y
    } else {
      py = backward[c - 1]
      y = py - 1
    }
    let mut x = self.left + (y - self.top) + k
    let px = if depth == 0 || y != py { x } else { x + 1 }
    while x > self.left && y > self.top && old[x - 1].text == new[y - 1].text {
      x = x - 1
      y = y - 1
    }
    backward[c] = y
    if is_even(self.delta()) && (k >= -depth && k <= depth) && x <= forward[k] {
      return Some(Snake::{ start: (x, y), end: (px, py) })
    }
  }
  return None
}
```



## 总结

除了默认的 diff 算法之外，Git 还提供了另一种 diff 算法，称为 `patience diff`。它在方法上与 Myers diff 有很大不同，有时会产生更可读的 diff 结果。

# Myers diff 3

本文是 [diff 系列](https://docs.moonbitlang.cn/example/myers-diff/index.html) 的第三篇。在 [上一部分](https://docs.moonbitlang.cn/example/myers-diff/myers-diff2.html) 中，我们探讨了完整的 Myers 算法及其局限性。在这篇文章中，我们将学习如何实现 Myers 算法的一种变体，该算法具有线性空间复杂度。

## 分而治之

Git 使用的 Myers 的 diff 算法的线性变体采用了一个称为 *Snake*（有时称为 *Middle Snake*）的概念来分解整个搜索过程。编辑图中的 Snake 表示在一次向左或向下移动后的 0 到 N 步的对角线移动。线性 Myers 算法在最优编辑路径上找到中间的 Snake，并用它将整个编辑图分成两部分。随后的步骤将相同的技术应用于结果子图，最终生成完整的编辑路径。

```
    0   1   2   3   4   5   6   7   8   9  10  11  12  13  14
 0  o---o---o---o---o---o---o
    |   |   |   |   |   |   |
 1  o---o---o---o---o---o---o
    |   | \ |   |   |   |   |
 2  o---o---o---o---o---o---o
    |   |   |   |   |   |   |
 3  o---o---o---o---o---o---o
    |   |   |   |   | \ |   |
 4  o---o---o---o---o---o---o
    |   |   |   |   |   |   |
 5  o---o---o---o---o---o---o
                              \
 6                              @
                                  \
 7                                  @---o---o---o---o---o---o
                                        |   |   |   |   |   |
 8                                      o---o---o---o---o---o
                                        | \ |   |   |   |   |
 9                                      o---o---o---o---o---o
                                        |   |   |   |   |   |
10                                      o---o---o---o---o---o
                                        |   |   |   |   |   |
11                                      o---o---o---o---o---o
                                        |   |   | \ |   |   |
12                                      o---o---o---o---o---o
                                        |   |   |   |   |   |
13                                      o---o---o---o---o---o
                                        |   |   |   |   | \ |
14                                      o---o---o---o---o---o
```



> 简要回顾一下：最佳编辑路径是到端点的距离最短的路径（对角线距离为零），并且可以有多个这样的路径。

细心的读者可能已经注意到一个鸡生蛋还是蛋生鸡的问题：为了找到 Snake，你需要一个最优的编辑路径，但是为了获得最优的编辑路径，你似乎需要先运行原始的 Myers 算法。

事实上，线性 Myers 算法背后的思想有些不寻常：它从左上角和右下角替换原始 Myers 算法，但不存储历史。相反，它只是检查两边的搜索是否重叠。当它们这样做时，重叠的部分作为 `Middle Snake` 返回。

这种方法似乎很简单，但仍有一些细节需要解决。

当从右下搜索时，对角线坐标不能再被称为 *k*。我们需要定义一个新的对角线坐标 **c = k - delta** 。这个坐标是 *k* 的镜像，非常适合反向搜索。

```
        x                       k
                                  0     1     2     3
        0     1     2     3         \     \     \     \
  y  0  o-----o-----o-----o           o-----o-----o-----o
        |     |     |     |      -1   |     |     |     | \
        |     |     |     |         \ |     |     |     |   2
     1  o-----o-----o-----o           o-----o-----o-----o
        |     | \   |     |      -2   |     | \   |     | \
        |     |   \ |     |         \ |     |   \ |     |   1
     2  o-----o-----o-----o           o-----o-----o-----o
                                        \     \     \     \
                                        -3    -2    -1      0
                                                              c
```



我们如何确定搜索是否重叠？只需检查正向搜索中对角线上的位置的 *x* 值是否大于反向搜索中的 *x* 值。但是，由于同一对角线的 *k* 和 *c* 坐标不同，因此转换可能有点棘手。

### 代码实现

我们将首先定义 `Snake` 和 `Box` 类型，代表 `middle snake` 和子编辑图（因为它们是方形的，所以我们称之为 `Box`）。

```
///
struct Box {
  left : Int32
  right : Int32
  top : Int32
  bottom : Int32
}

///|
struct Snake {
  start : (Int32, Int32)
  end : (Int32, Int32)
}

///|
fn Box::width(self : Self) -> Int32 {
  self.right - self.left
}

///|
fn Box::height(self : Self) -> Int32 {
  self.bottom - self.top
}

///|
fn Box::size(self : Self) -> Int32 {
  self.width() + self.height()
}

///|
fn Box::delta(self : Self) -> Int32 {
  self.width() - self.height()
}
```



为了避免太早陷入细节，让我们假设我们已经有一个函数：`midpoint : (Box, Array[Line], Array[Line]) -> Snake?` 去找 `middle snake`。然后，我们可以构建函数 `find_path` 来搜索完整的路径。

```
///
fn Box::find_path(
  box : Self,
  old~ : Array[Line],
  new~ : Array[Line],
) -> Iter[(Int32, Int32)]? {
  guard box.midpoint(old~, new~) is Some(snake) else { None }
  let start = snake.start
  let end = snake.end
  let headbox = Box::{
    left: box.left,
    top: box.top,
    right: start.0,
    bottom: start.1,
  }
  let tailbox = Box::{
    left: end.0,
    top: end.1,
    right: box.right,
    bottom: box.bottom,
  }
  let head = headbox.find_path(old~, new~).unwrap_or(Iter::singleton(start))
  let tail = tailbox.find_path(old~, new~).unwrap_or(Iter::singleton(end))
  Some(head.concat(tail))
}
```



`find_path` 的实现很简单，但 `midpoint` 有点复杂：

- 对于大小为 0 的 `Box`，返回 `None`。
- 计算搜索边界。因为向前和向后搜索各占一半的距离，所以除以 2。但是，如果 `Box` 的大小是奇数，则在正向搜索边界上再添加一个。
- 将向前和向后搜索的结果存储在两个数组中。
- 在向前和向后搜索之间交替，如果没有找到结果则返回 `None`。

```
///|
fn Box::midpoint(self : Self, old~ : Array[Line], new~ : Array[Line]) -> Snake? {
  if self.size() == 0 {
    return None
  }
  let max = {
    let half = self.size() / 2
    if is_odd(self.size()) {
      half + 1
    } else {
      half
    }
  }
  let vf = BPArray::make(2 * max + 1, 0)
  vf[1] = self.left
  let vb = BPArray::make(2 * max + 1, 0)
  vb[1] = self.bottom
  for d = 0; d < max + 1; d = d + 1 {
    match self.forward(forward=vf, backward=vb, d, old~, new~) {
      None =>
        match self.backward(forward=vf, backward=vb, d, old~, new~) {
          None => continue
          res => return res
        }
      res => return res
    }
  } nobreak {
    None
  }
}
```



与最初的 Myers 算法相比，向前和向后搜索有一些修改，需要做出解释：

- 因为我们需要返回 `snake`，所以搜索过程必须计算前一个坐标（`px` 代表前一个 x）。
- 搜索现在在 `Box`（不是全局编辑图）中工作，因此从 `x` 计算 `y` 需要转换（反之亦然）。
- 反向搜索最小化 `y` 是一种启发式策略，但最小化 `x` 也是可行的。

```
///|
fn Box::forward(
  self : Self,
  forward~ : BPArray[Int32],
  backward~ : BPArray[Int32],
  depth : Int32,
  old~ : Array[Line],
  new~ : Array[Line],
) -> Snake? {
  for k = depth; k >= -depth; k = k - 2 {
    let c = k - self.delta()
    let mut x = 0
    let mut px = 0
    if k == -depth || (k != depth && forward[k - 1] < forward[k + 1]) {
      x = forward[k + 1]
      px = x
    } else {
      px = forward[k - 1]
      x = px + 1
    }
    let mut y = self.top + (x - self.left) - k
    let py = if depth == 0 || x != px { y } else { y - 1 }
    while x < self.right && y < self.bottom && old[x].text == new[y].text {
      x = x + 1
      y = y + 1
    }
    forward[k] = x
    if is_odd(self.delta()) &&
      (c >= -(depth - 1) && c <= depth - 1) &&
      y >= backward[c] {
      return Some(Snake::{ start: (px, py), end: (x, y) })
    }
  }
  return None
}

///|
fn Box::backward(
  self : Self,
  forward~ : BPArray[Int32],
  backward~ : BPArray[Int32],
  depth : Int32,
  old~ : Array[Line],
  new~ : Array[Line],
) -> Snake? {
  for c = depth; c >= -depth; c = c - 2 {
    let k = c + self.delta()
    let mut y = 0
    let mut py = 0
    if c == -depth || (c != depth && backward[c - 1] > backward[c + 1]) {
      y = backward[c + 1]
      py = y
    } else {
      py = backward[c - 1]
      y = py - 1
    }
    let mut x = self.left + (y - self.top) + k
    let px = if depth == 0 || y != py { x } else { x + 1 }
    while x > self.left && y > self.top && old[x - 1].text == new[y - 1].text {
      x = x - 1
      y = y - 1
    }
    backward[c] = y
    if is_even(self.delta()) && (k >= -depth && k <= depth) && x <= forward[k] {
      return Some(Snake::{ start: (x, y), end: (px, py) })
    }
  }
  return None
}
```



## 总结

除了默认的 diff 算法之外，Git 还提供了另一种 diff 算法，称为 `patience diff`。它在方法上与 Myers diff 有很大不同，有时会产生更可读的 diff 结果。

# 线段树（第一部分）

## 线段树是什么？

本节是纯粹的概念、理论内容，如果读者已经了解并且熟悉线段树的构成与其原理，可以直接阅读下一节内容。

就像引言当中所说的，线段树可以解决一类区间问题，但他长什么样子，能做到如此优秀复杂度的原理又是什么呢？

我们以下图一个线性的数字序列为例，如果我们希望以它建立一棵线段树，那么它将会长这个样子：

![构建线段树](https://docs.moonbitlang.cn/_images/segment-tree-build.png)

可以看到我们把一个线性序列的区间层层分而治之，每次分割为两个对等（如果是奇数则一边多一个）的两个区间（区间范围下标在图示中），最终直到分割为长度为一的区间，并且在此过程中计算了其中每个区间元素的加和（在括号中），这样就从一个线性序列创建了一棵支持查询区间和线段树。

那么在查询区间和的时候，它如何工作呢？我们以查询区间 1-6 的和为例：

![查询线段树](https://docs.moonbitlang.cn/_images/segment-tree-query.png)

可以发现图中的标红部分加起来就等于区间 1-6 的区间和，而我们并没有统计到所有元素，只是选取了最少的区间来频出我们需要求解的区间，并且把我们要求的结果（此处为和）合并起来即可得到最终解。而我们只需要从上到下遍历这棵线段树来判断区间之间的交集/包含关系即可选择到符合条件的区间。

具体来说：

- 首先询问区间 1-7 与 1-6 的关系，显然后者为前者的子集，当前 1-7 的数据不能用于统计，因此继续向下遍历两个子节点。
- 再询问 1-3 与 1-6 的关系，前者为后者的子集，可以作为解的一部分，统计入当前结果中。
- 接下来询问 4-7 与 1-6 的关系，二者有交集，因此要继续向下遍历两个子节点。
- 然后询问 4-5 与 1-6 的关系，此处与第三条一致。
- 以此类推...

根据二进制分解的知识，我们对任何长度为 N 的区间最多只会求解 Log N 个区间，因此复杂度是可以保证的。

这里仅聊到查询操作，关于线段树上的修改操作的原理和实现我们将会在下一节详细说明。

## 实现

### 基础定义

我们采用一个非常经典的方法来表达线段树：

```
enum Node {
  Nil
  Node(Int32, Node, Node)
}
```



其中 `Nil` 代表空树，而一个 `Node` 则包含一个它所储存的数据（为 Int32 类型）和左右两个节点。

### 建树

建树是指将一个线性序列抽象为线段树的过程，一般将其称为 `build`。

作为前置，我们应该根据需求为 `Node` 类型编写一个 `add` 的重载来配合下面建树的过程：

```
impl Add for Node with add(self : Node, v : Node) -> Node {
  match (self, v) {
    (Node(left, _, _), Node(right, _, _)) => Node(left + right, self, v)
    (Node(_), Nil) => self
    (Nil, Node(_)) => v
    (Nil, Nil) => Nil
  }
}
```



定义这一运算之后就可以轻松的向上合并两个 `Node` 节点，并在此过程中维护区间的和，为我们建树打下了基础，在有些线段树的叙述当中，这个过程也叫做 `pushup`。

我们可以用 MoonBit 的 `ArrayView` 特性（某些语言当中也叫做 `slice` ）作为参数来低成本的取出一个线性结构的一段进行递归建树，这个过程是 `O(N Log N)` 的：

```
fn build(data : ArrayView[Int32]) -> Node {
  if data.length() == 1 {
    Node(data[0], Nil, Nil)
  } else {
    let mid = (data.length() + 1) >> 1
    build(data[0:mid]) + build(data[mid:])
  }
}
```



分析一下这段代码：

- 首先如果当前长度已经为 1，就证明该区间不再需要细分，直接返回左右分支为空的叶子节点。
- 否则就证明该区间还可被分割，则求其中间值将其分割为两个区间分而治之的建树再通过 `Node` 之间的加法合并。

这段代码是非常简洁、可读性非常高的，而且对优化非常友好，可以作为后续其他数据结构的范式学习。

让我们来建立一棵树并测试看看：

```
test {
  let tree = build([1, 2, 3, 4, 5][:])
  json_inspect(tree, content=[
    15,
    [6, [3, [1, "Nil", "Nil"], [2, "Nil", "Nil"]], [3, "Nil", "Nil"]],
    [9, [4, "Nil", "Nil"], [5, "Nil", "Nil"]],
  ])
}
```



漂亮，我们已经成功完成了建树的过程！

### 查询

接下来我们要编写查询，因为这棵线段树的节点向上合并时维护的是区间和，因此我们可以编写一个 `query` 函数来查询它：

```
let empty_node : Node = Node(0, Nil, Nil)

///|
fn Node::query(
  self : Node,
  l : Int32,
  r : Int32,
  query_l : Int32,
  query_r : Int32,
) -> Node {
  if query_l > r || l > query_r {
    empty_node
  } else if query_l <= l && query_r >= r {
    self
  } else {
    guard! self is Node(_, left, right)
    let mid = (l + r) >> 1
    left.query(l, mid, query_l, query_r) +
    right.query(mid + 1, r, query_l, query_r)
  }
}
```



首先，`l` 与 `r` 是当前函数中已经查询到的区间，`query_l` 与 `query_r` 是需要查询的区间，让我们来尝试解析一下这段实现：

- 如果需查询的区间和当前的区间状态为互不相交，则对解没有贡献，我们定义了一个 `empty_node` 来表示 0 贡献节点，将其返回则为无贡献。
- 如果当前区间就是需查询区间的子集，那么实际上对解的贡献就是它自己，直接返回它即可。
- 如果当前区间和需要查询的区间存在交集关系，那么需要继续向下搜索来确定准确的覆盖，因此继续求出中间值向下搜索并且合并两边的 `Node` 结果。

#### 在继续之前

注意被高亮的行。在使用 let 解构 Node 时，我们是可以确定要解构的 enum 一定不是 Nil，但编译器是不能确定这一点的的，所以如果我们尝试这样去解构它：

```
let Node(x, y) = z
```



会发现编译器实际上给我们了一个警告。尽管不影响运行，但有些误导。因此我们可以用，MoonBit 的 guard 语句，用 guard let 这种方法来更好的解决这种需求：

```
guard let Node(x, y) = z
```



### 问与答

- 问：为什么要用 `Node` 作为返回值，我用相同的逻辑也可以直接把 `Node` 当中的值给解构出来相加呀？
- 答：首先，我们为 `Node` 已经编写了加和运算，不妨考虑一种情况，我们不止要维护区间和，而是要同时维护区间和还有区间最小值，这时候我们只需要更改 `Node` 的 `add` 逻辑来维护最小值即可，而 `query` 函数和我们要维护的数据没有关系，它最终返回的是一个 `Node` ，它可以求出所有信息！所以不妨就让我们使用 `Node`！
- 问：你说的这种情况 `empty_node` 是不是也要改变？
- 答：对，`empty_node` 是用来保证它和任何其他 `Node` 相加都不会产生改变的元素，是一个零贡献的`Node` ，类比在维护区间和的时候零贡献是 0，那么其实对于维护最小值来说你的值是当前可以取到的最大值，那就是零贡献的，这个过程处理的其实很灵活！

让我们来测试一下这个查询过程：

```
test {
  let tree = build([1, 2, 3, 4, 5][:])
  let sum = match tree.query(1, 5, 1, 3) {
    Node(sum, _, _) => sum
    _ => fail("Expected Node")
  }
  inspect(sum, content="6")
}
```



输出是：`6`。

太好了，我们得到了正确的输出！

### 代码

完整代码请查看 [GitHub 代码仓库](https://github.com/moonbitlang/moonbit-docs/tree/main/next/sources/segment-tree/src/part1/top.mbt)。

## 总结

今天我们学习了如何编写一棵简单的线段树的构建和查询操作的编写，下一节课我们将会学习更加复杂的线段树的原理和实现，感兴趣的读者可以在阅读文章之后自行实现下面内容来巩固知识和拓展更多内容：

- 尝试实现一个可以维护多个信息（如区间和、区间最大值最小值）的线段树。
- 自行了解如何实现线段树的单点查询/修改操作并实现。
- 自行了解线段树的区间修改操作以及 LazyTag 的相关知识。

# 线段树（第二部分）

## 介绍

在上一篇文章当中我们讨论了最基础线段树的实现，但那棵线段树只能做到区间的查询（当然单点的修改与查询也是可以的），但做不到区间的修改（一个经典的应用是区间加法，即整个区间都加上某个值）。

在本节当中我们将基于上次的线段树继续加深抽象，引入 LazyTag 的概念来解决区间修改的问题，完成一棵功能基本完备的线段树。

## 怎么做到区间修改？

先设想如果我们在线段树上给一个区间都加上某个数会发生什么？或者换种说法，以最简单的办法来说，我们是如何完成它的？

![插入线段树](https://docs.moonbitlang.cn/_images/segment-tree-add.png)

以上节课的线段树为例，上面这张图中，我们对 [4, 7] 的区间都加上 1。这时候我们会发现这需要把涉及到这段区间的所有树上部分都重新构建维护一次，这个时间代价我们肯定是不能接受的。

那有没有更好的方法？当然有！可以使用 LazyTag！

![lazytag](https://docs.moonbitlang.cn/_images/segment-tree-lazytag.png)

设想我们在操作时，仅把 [4, 7] 区间的最少覆盖区间（就像查询需要的区间一样）打上一个“+1” 的标记，并且根据这个区间的长度计算他应该有的值，然后合并上去，根据上节课 query 的复杂度类推，这个操作的复杂度应为 O(Log N) 的。

但有个问题，现在这种处理方法查询 [1, 7] 或者 [4, 7] 这些区间都没有问题，但如果我们要查询 [4, 6] 呢？容易发现对于区间 [4, 6]，它的最小覆盖区间是 [4, 5] 与 [6, 6] 而不是 [4, 7]，我们的 Tag 并没有对下面的节点生效。

下面我们就要用到 LazyTag 除了 Tag 外的另一个性质：Lazy。

![使用 lazytag 插入](https://docs.moonbitlang.cn/_images/segment-tree-add-lazytag.png)

我们规定在查询到某个节点时，如果当前节点上有一个加法的 Tag，就把它分发给下面的节点，下面的节点同样接收这个 Tag 并且根据自己的长度计算出自己应有的值。上图展示了在查询区间 [4, 6] 的结果时发生的 Tag 向下分发的操作。非常符合直觉的，叶子节点接收 Tag 之后可以直接转换为自身的改变而不需要再保留 Tag。

容易发现像这样的“懒惰下推 Tag”的方法可以保证每次修改的操作在 O(Log N) 的时间内完成，还可以保证查询时可以查询到正确的结果！

备注

可能有些同学会疑问如果 Tag 重叠会怎么样，如果我们尝试一下就可以发现上文的这种加法 Tag 之间其实具有良好的合并性，不影响该节点总和的计算。

让我们来试试代码实现吧！

## 实现

### 基础定义

上节课的代码当中使用 enum 定义了线段树，但是每个 enum 当中的每个元素是用来干什么的其实没有名称标识，因为数据量比较小，对我们的心智负担影响不大，但目前我们需要添加 Tag 和 Length 属性存储，会显得匹配和定义的时候无法区分参数。所以我们可以使用 enum 的 labeled-argument 写法来完成更好的定义：

```
///|
enum Data {
  Data(sum~ : Int32, len~ : Int32)
}

///|
enum LazyTag {
  Nil
  Tag(Int32)
}

///|
enum Node {
  Nil
  Node(data~ : Data, tag~ : LazyTag, left~ : Node, right~ : Node)
}
```



这样我们就清晰地完成了对数据、LazyTag 和节点结构的定义，在下面初始化与模式匹配时将会更加清晰。另外，我们把 Data 类型单独抽象出来，比上节课多了一个 len 属性，用来标记当前区间的长度，以配合 Tag 计算当前节点的值。

### 建树

我们依然像上一节一样在编写建树逻辑之前需要先考虑 Node 类型之间的加法，但本节中因为我们单独抽象了 Data，所以也要考虑他们之间的加法：

```
///|
impl Add for Data with add(self : Data, v : Data) -> Data {
  match (self, v) {
    (Data(sum=a, len=len_a), Data(sum=b, len=len_b)) =>
      Data(sum=a + b, len=len_a + len_b)
  }
}

///|
impl Add for Node with add(self : Node, v : Node) -> Node {
  match (self, v) {
    (Node(data=l, ..), Node(data=r, ..)) =>
      Node(data=l + r, tag=Nil, left=self, right=v)
    (Node(_), Nil) => self
    (Nil, Node(_)) => v
    (Nil, Nil) => Nil
  }
}
```



可以发现这里暂时还没有考虑 LazyTag 的合并，而是认为他们加法的结果得到的节点的 LazyTag 均为 Nil，这是很好理解的，如果已经走到一个节点，那么它的父节点当然会是没有 LazyTag 的。

接下来就可以写出建树的代码，这与上节非常相似：

```
///|
fn build(data : ArrayView[Int32]) -> Node {
  if data.length() == 1 {
    Node(data=Data(sum=data[0], len=1), tag=Nil, left=Nil, right=Nil)
  } else {
    let mid = (data.length() + 1) >> 1
    build(data[0:mid]) + build(data[mid:])
  }
}
```



### LazyTag 与区间修改的实现

我们把一个节点接受一个 LazyTag 的行为定义为 apply，容易发现其实真正的核心逻辑就在这里，当前接受上方 LazyTag 的节点身上不一定是否有 LazyTag，而如果有，又应该怎么合并？怎么根据 LazyTag 计算当前节点新的值？答案都在这个操作当中。

一个很好的实现方法是我们对 LazyTag 再单独定义一套加法运算来实现他们的合并，然后为 Node 类型编写一个 apply 函数来接收一个 LazyTag。

```
///|
impl Add for LazyTag with add(self : LazyTag, v : LazyTag) -> LazyTag {
  match (self, v) {
    (Tag(a), Tag(b)) => Tag(a + b)
    (Nil, t) | (t, Nil) => t
  }
}

///|
fn Node::apply(self : Node, v : LazyTag) -> Node {
  match (self, v) {
    (Node(data=Data(sum=a, len=length), tag~, left~, right~), Tag(v) as new_tag) =>
      Node(
        data=Data(sum=a + v * length, len=length),
        tag=tag + new_tag,
        left~,
        right~,
      )
    (_, Nil) => self
    (Nil, _) => Nil
  }
}
```



这是我们这节课最核心的地方，根据当前区间长度和 LazyTag 的值计算出了当前节点的正确数值，这样我们就有了 LazyTag 的实现。

怎么做到区间修改？

```
///|
fn Node::modify(
  self : Node,
  l : Int32,
  r : Int32,
  modify_l : Int32,
  modify_r : Int32,
  tag : LazyTag,
) -> Node {
  if modify_l > r || l > modify_r {
    self
  } else if modify_l <= l && modify_r >= r {
    self.apply(tag)
  } else {
    guard! self is Node(left~, right~, ..)
    let mid = (l + r) >> 1
    left.modify(l, mid, modify_l, modify_r, tag) +
    right.modify(mid + 1, r, modify_l, modify_r, tag)
  }
}
```



逻辑实际上与上节课编写的 query 大差不差，只是每个地方都让对应的节点 apply 了我们需要修改的值（作为 LazyTag）。

不过写到这里我们可以发现，这棵线段树就算加入了区间修改之后居然还是一个可持久化的，或者说 Immutable 的线段树！我们的 modify 函数将会返回最新的那棵线段树，并没有对原来的线段树作任何改变，而我们的递归与合并语义非常明显的体现了这一点。

这说明在一些 Immutable 的需求上上采用这类写法（ADT(enum)、递归）是非常优雅而且自然的。而且 MoonBit 语言存在垃圾回收机制 (GC)，所以在无限递归的 ADT(enum) 当中不需要**显式地**用指针来指代一些关系，我们并不需要关心内存里面发生了什么。

很多对函数式编程语言不熟悉的读者可能使用 MoonBit 时没有太关注到这个问题，但其实我们一直从中受益，比如如果我们需要在 Rust 当中使用 ADT(enum) 来写一个 ConsList，我们往往需要：

```
enum List<T> {
    Cons(T, Box<List<T>>),
    Nil,
}
```



但在 MoonBit，我们只需要：

```
enum List[T] {
  Cons(T, List[T])
  Nil
}
```



GC 真的很有趣！

### 查询

查询部分只要记得需要下推 LazyTag 即可。

```
///|
let empty_node : Node = Node(
  data=Data(sum=0, len=0),
  tag=Nil,
  left=Nil,
  right=Nil,
)

///|
fn Node::query(
  self : Node,
  l : Int32,
  r : Int32,
  query_l : Int32,
  query_r : Int32,
) -> Node {
  if query_l > r || l > query_r {
    empty_node
  } else if query_l <= l && query_r >= r {
    self
  } else {
    guard! self is Node(tag~, left~, right~, ..)
    let mid = (l + r) >> 1
    left.apply(tag).query(l, mid, query_l, query_r) +
    right.apply(tag).query(mid + 1, r, query_l, query_r)
  }
}
```



## 总结

到这里我们就完成了一棵支持区间修改的，更加完美的线段树！

接下来，在最后一节课当中我们将会学习如何给当前这棵线段树再加入一个“乘法操作”，以及探索一些 Immutable 线段树的应用场景。感兴趣的读者可以提前自行了解。

完整代码在 [这里](https://docs.moonbitlang.cn/_downloads/d087ac87400271bbac0155b3d6da7d2c/top.mbt)。