## FormeFileGrid

**this package only provide move,sort,display your picked files. you must implement file picker via file_picker or other packages by yourself**

### example

https://www.qyh.me/forme3/index.html

### screenshot

![forme_file_grid](https://raw.githubusercontent.com/wwwqyhme/forme/main/forme_file_picker/forme_file_grid.gif)

### Usage 

``` dart
 FormeFileGrid({
  Duration? animateDuration,/// animate duration , default 150ms
  int? maximum,/// the maximum number of files can holded , null means unlimited , default is null
  required SliverGridDelegate gridDelegate,
  InputDecoration? decoration,
  bool showFilePickerWhenReadOnly = true,// whether show picker when readOnly ,default true
  bool disableFilePicker = false,//disable file picker always , default is false
  Color? filePickerColor,// picker color , default is Colors.grey.withOpacity(0.3)
  Color? filePickerDisabledColor,/// color when picker disabled ,default is Theme.of(context).disabledColor
  Widget? filePickerChild, /// child of file picker , default is Icon(Icons.add)
  bool showGridItemRemoveWidget = true,/// whether show remove icon on grid item
  Curve? slideCurve,
   /// builder display widget  when thumbnail create failed or image loading failed
   Widget Function(
      BuildContext context,
      FormeFile item,
      VoidCallback retry,
      Object error,
      StackTrace? stackTrace)? imageLoadingErrorBuilder,
  BoxFit imageFit = BoxFit.cover,/// image fit
  bool Function(FormeFile, int)? removable,/// whether a file or index can be removed , you can still remove them by [FormeFileGridState]
  bool Function(FormeFile, int)? draggable,/// whether a file or index is draggable
  Duration? longPressDelayStartDrag,/// long press delay when start drag , default is 500ms
  Widget Function(BuildContext, FormeFile, int, Widget)? childWhenDraggingBuilder,/// child builder when dragging
  Widget Function(BuildContext, FormeFile, int, Widget, Size?)? feedbackBuilder,/// feedback builder when dragging
  bool reOrderable = true, /// whether files is reorderable by drag
  Widget Function(
    BuildContext context,
    FormeFile item,
    Widget child,
    ImageChunkEvent? loadingProgress,
    bool isImageLoaded,
  )? imageLoadingBuilder,/// [loadingProgress] still can be null though [isImageLoaded] is false
  ValueChanged<FormeFile>? onGridItemTap,
  OnFileUploadSuccess? onUploadSuccess,//triggered after successful upload
  ONFileUploadFail? onUploadFail,//triggered when upload failed
  void Function(FormeFileGridState state, int? maximum) pickFiles,///use [FormeFileGridState.insertFiles] to insert your picked files
  Widget Function(FormeFileGridState state)? filePickerBuilder,/// used to build pick widget
   /// builder display widget  when thumbnail future is working
  Widget Function(
    BuildContext context,
    FormeFile item,
  )? thumbnailLoadingBuilder,
  /// default is BoxDecoration(color: Colors.black.withOpacity(0.3))
  BoxDecoration? uploadBackgroundDecoration,
  IconData? uploadErrorIconData,
  IconData? uploadIconData,
  Color? uploadErrorIconColor,
  Color? uploadIconColor,
  Widget? gridItemRemoveWidget,
})
```

### FormeFile

``` dart
abstract class FormeFile {
  Future<ImageProvider> get thumbnail; /// get file thumbnail
}
```

#### UploadableFormeFile

``` dart
abstract class UploadableFormeFile<T> extends FormeFile {
  Future<T> upload();
  /// override this method if your upload is cancellable
  void cancelUpload() {}
  bool get autoUpload => false;
}
```