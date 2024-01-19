# markdown_editor



``` dart
MarkdownEditor(
      initText: 'initText',
      initTitle: 'initText',
      onTapLink: (link){
        print('link tapped $link');
      },
      imageWidget: (imageUrl) {
        return // Your image widget ;
      },
      imageSelect: (){ // Click image select btn
        return // selected image link;
      },
)
```
