import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:markdown_editor/markdown_editor.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _launchURL(String url) async {
    await launchUrlString(url);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300),
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child: MarkdownEditor(
                isEditorExpanded: true,
                initText: """
Markdown is a markup language that can be written using an ordinary text editor. Through simple markup syntax, it can make ordinary text content have a certain format. For more introduction, please refer to [Baidu Encyclopedia](https://baike.baidu.com/item/markdown/3245).

## 1.Title
Add a pound sign at the beginning of the line to indicate different levels of titles (H1-H6), for example: # H1, ## H2, ### H3, #### H4 (note: there should be an English space after the # sign).
#Level 1 title
## Second level title
### Third level title
#### Level 4 heading
##### Level 5 headings
###### Sixth level title

## 2. Text effect

Use * to surround text to indicate *italic*, such as: \\*italic*.
Use ** to surround text to represent **bold**, such as: \\*\\*bold**.
Use ~~ to surround text to represent ~~strikethrough~~, such as: \\~\\~strikethrough~~.

If you want to highlight part of the text in a paragraph to highlight it, you can surround it with \\`, `note` that this is not a single quotation mark, but above ``Tab``, ` The key to the left of `number 1` (note that you use the `English` input method).

## 3. External links

Use \\[Description](link address) to add external links to text.
This is a link to [Old Time Website](https://www.jiushig.com).

## 4. Pictures

Use \\!\\[Description] (image link address) to insert an image, just one more ! sign than in front of the link. Example of inserting a picture:

![Old time](https://oss.jiushig.com/oldtime/oldtime_wallpaper.png)

## 5. List

Use *, +, - to represent an unordered list.

- Unordered list items 1
- Unordered list items 2
- Unordered list items three

Adding four spaces at the beginning of the line represents a secondary list, and so on.

+ first level list
    + Secondary list
              + Level 3 list

## 6. Quote

Use > at the beginning of a line to indicate a literal reference.

Single quote:

> Wildfires never burn out, but spring breezes blow them again. Wild fire, in spring.

Of course, you can also use multiple >>

>I used a
>> I used two

## 7. Fragments

You can use ``` to wrap a piece of text to display a certain fragment, for example, to display the following code fragment:

```
\$(document).ready(function () {
    alert('RUNOOB');
});
```

## 8. Table

                """,
                isPreviewExpanded: true,
                editorPadding: const EdgeInsets.all(8),
                textStyle: const TextStyle(
                  fontSize: 18,
                  height: 1.8,
                  color: Colors.black,
                ),
                onTapLink: (link) => _launchURL(link),
                previewImageWidget: (imageUrl) {
                  debugPrint('imageUrl $imageUrl');
                  return CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => const SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
