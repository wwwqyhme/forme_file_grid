import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

import 'draggable_grid_view.dart';
import 'forme_upload_controller.dart';
import 'upload_stack.dart';

typedef FilePickerBuilder = Widget Function(
  FormeFileGridState field,
);
typedef OnFileUploadSuccess = void Function(FormeFile file, dynamic result);
typedef OnFileUploadFail = void Function(
    FormeFile file, Object error, StackTrace? stackTrace);

class FormeFileGrid extends FormeField<List<FormeFile>> {
  FormeFileGrid({
    this.maximum,
    super.key,
    super.name,
    super.initialValue = const [],
    super.asyncValidator,
    super.asyncValidatorDebounce,
    super.autovalidateMode,
    FormeFieldDecorator<List<FormeFile>>? decorator,
    super.enabled = true,
    super.focusNode,
    super.onInitialized,
    super.onSaved,
    super.onStatusChanged,
    super.order,
    super.quietlyValidate = false,
    super.readOnly = false,
    super.requestFocusOnUserInteraction = true,
    super.validationFilter,
    super.validator,
    this.showFilePickerWhenReadOnly = true,
    this.disableFilePicker = false,
    this.filePickerColor,
    this.filePickerDisabledColor,
    this.filePickerChild,
    this.showGridItemRemoveWidget = true,
    this.imageLoadingErrorBuilder,
    this.imageFit = BoxFit.cover,
    this.removable,
    this.draggable,
    this.longPressDelayStartDrag,
    this.childWhenDraggingBuilder,
    this.feedbackBuilder,
    this.reOrderable = true,
    this.imageLoadingBuilder,
    this.onUploadSuccess,
    this.onUploadFail,
    required this.pickFiles,
    this.filePickerBuilder,
    this.thumbnailLoadingBuilder,
    this.uploadBackgroundDecoration,
    this.uploadErrorIconColor,
    this.uploadErrorIconData,
    this.uploadIconColor,
    this.uploadIconData,
    this.gridItemRemoveWidget,
    this.onGridItemTap,
    this.gridViewPadding,
    this.physics,
    this.scrollController,
    this.shrinkWrap = true,
    this.slideCurve,
    this.animateDuration,
    this.decoration,
    required this.gridDelegate,
  }) : super.allFields(
            decorator: decorator ??
                (decoration == null
                    ? null
                    : FormeInputDecorationDecorator(
                        decorationBuilder: (context) => decoration,
                        maxLength: maximum,
                        counter: (value) => value.length,
                      )),
            builder: (genericState) {
              final FormeFileGridState state =
                  genericState as FormeFileGridState;
              return DraggableGridView<_Item<FormeFile>>(
                scrollController: scrollController,
                physics: physics ?? const NeverScrollableScrollPhysics(),
                shrinkWrap: shrinkWrap,
                padding: gridViewPadding,
                reOrderable: reOrderable,
                slideCurve: slideCurve,
                animateDuration:
                    animateDuration ?? const Duration(milliseconds: 150),
                gridDelegate: gridDelegate,
                onAccept: state._onAccept,
                builder: (context, item, index) {
                  if (maximum != null &&
                      state._gridController.value.length - 1 >= maximum &&
                      item.value == null) {
                    return Container();
                  }
                  Widget child;
                  if (item.value == null) {
                    child = state._buildFilePicker.call(state);
                  } else {
                    child = GestureDetector(
                      onTap: onGridItemTap == null
                          ? null
                          : () {
                              onGridItemTap.call(item.value!, state.value);
                            },
                      child: state._gridItem.call(item.value!, index),
                    );
                  }
                  return child;
                },
                draggableConfiguration: state._draggableConfiguration(),
                controller: state._gridController,
              );
            });
  final int? maximum;

  /// used to build your custom file picker
  final FilePickerBuilder? filePickerBuilder;

  /// file picker color , default [Colors.grey.withOpacity(0.3)]
  final Color? filePickerColor;

  /// color when file picker is not clickable , default is Theme.of(context).disabledColor
  final Color? filePickerDisabledColor;

  /// child of file picker , default is Icon(Icons.add)
  final Widget? filePickerChild;

  /// whether show file picker when readOnly or disabled, default is true
  final bool showFilePickerWhenReadOnly;

  /// whether show file picker or not
  final bool disableFilePicker;

  /// whether show remove icon or not
  final bool showGridItemRemoveWidget;

  /// whether an image can be removed by user interactive
  ///
  /// **if you only check removable by index , the file at index can still be removed after sort by drag , use [draggable] disable drag conditonal**
  ///
  /// **you call still remove this image by [FormeFileGridState]**
  final bool Function(FormeFile image, int index)? removable;

  final Widget? gridItemRemoveWidget;

  /// builder display widget  when thumbnail create failed or image loading failed
  final Widget Function(
      BuildContext context,
      FormeFile item,
      VoidCallback retry,
      Object error,
      StackTrace? stackTrace)? imageLoadingErrorBuilder;

  /// builder display widget  when thumbnail future is working
  final Widget Function(
    BuildContext context,
    FormeFile item,
  )? thumbnailLoadingBuilder;

  /// image loading builder
  ///
  /// loadingProgress still can be null though isImageLoaded is false
  final Widget Function(
    BuildContext context,
    FormeFile item,
    Widget child,
    ImageChunkEvent? loadingProgress,
    bool isImageLoaded,
  )? imageLoadingBuilder;

  /// image fit , default is [BoxFit.cover]
  final BoxFit imageFit;

  /// whether item is draggable , default  every item is draggable
  ///
  /// **if you only check draggable by index , the file at index can still be draggable after sort by drag **
  final bool Function(FormeFile item, int index)? draggable;
  final Duration? longPressDelayStartDrag;
  final Widget Function(
          BuildContext context, FormeFile item, int index, Widget child)?
      childWhenDraggingBuilder;
  final Widget Function(BuildContext context, FormeFile item, int index,
      Widget child, Size? size)? feedbackBuilder;

  /// use [FormeFileGridState.insertFiles] to insert your picked files
  final void Function(FormeFileGridState state, int? maximum) pickFiles;

  /// whether reOrderable on drag
  final bool reOrderable;

  /// default is BoxDecoration(color: Colors.black.withOpacity(0.4))
  final BoxDecoration? uploadBackgroundDecoration;

  final IconData? uploadErrorIconData;
  final IconData? uploadIconData;
  final Color? uploadErrorIconColor;
  final Color? uploadIconColor;

  final OnFileUploadSuccess? onUploadSuccess;
  final OnFileUploadFail? onUploadFail;
  final void Function(FormeFile tapped, List<FormeFile> value)? onGridItemTap;

  final Curve? slideCurve;
  final EdgeInsetsGeometry? gridViewPadding;
  final bool shrinkWrap;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;

  final SliverGridDelegate gridDelegate;
  final InputDecoration? decoration;
  final Duration? animateDuration;

  @override
  FormeFieldState<List<FormeFile>> createState() => FormeFileGridState();
}

class FormeFileGridState extends FormeFieldState<List<FormeFile>> {
  @override
  FormeFileGrid get widget => super.widget as FormeFileGrid;

  late GridController<_Item<FormeFile>> _gridController;

  late final ValueNotifier<bool> _draggingNotifer =
      FormeMountedValueNotifier(false);

  @override
  void initStatus() {
    super.initStatus();
    _gridController = GridController(_convert(List.of(initialValue)));
    _gridController.addListener(() {
      didChange(_gridController.value
          .where((element) => element.value != null)
          .map((e) => e.value!)
          .toList());
    });
  }

  /// when you have your own [DragTarget] and want to accept data from [FormeFileGrid]
  /// you can use this method in [DragTarget.onWillAccept]
  bool canAccept(dynamic data) => _gridController.canAccept(data);

  int? get maxInsertableNum => _maxInsetableNum;

  ValueListenable<bool> get draggingListenable =>
      FormeValueListenableDelegate(_draggingNotifer);

  List<_Item<FormeFile>> _convert(List<FormeFile> files) {
    List<_Item<FormeFile>> items = files.map((e) => _Item(e)).toList();
    if (widget.maximum != null && items.length > widget.maximum!) {
      items = items.sublist(0, widget.maximum);
    }

    final bool showFilePicker = !widget.disableFilePicker &&
        ((!readOnly && enabled) || widget.showFilePickerWhenReadOnly);
    if (showFilePicker &&
        (widget.maximum == null || items.length < widget.maximum!)) {
      items.add(const _Item.empty());
    }
    return items;
  }

  @override
  void dispose() {
    _draggingNotifer.dispose();
    _gridController.dispose();
    super.dispose();
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<List<FormeFile>> status) {
    super.onStatusChanged(status);
    if (status.isValueChanged) {
      _gridController.value = _convert(status.value);
      if (oldValue != null) {
        final List<UploadableFormeFile> removed = oldValue!.value
            .whereType<UploadableFormeFile>()
            .where((element) => !status.value.contains(element))
            .toList();
        for (final UploadableFormeFile file in removed) {
          file._uploadController?.cancel();
        }
      }
    }
  }

  void _removeByUserInteractive(FormeFile item, int index) {
    if (!mounted) {
      return;
    }
    if (widget.removable != null &&
        !widget.removable!(_gridController.value[index].value!, index)) {
      return;
    }
    remove([index]);
  }

  /// stop animations and commit changes
  void commit() {
    if (!mounted || _gridController.currentItems == null) {
      return;
    }
    _gridController.value = _convert(_gridController.currentItems!
        .where((element) => element.value != null)
        .map((e) => e.value!)
        .toList());
  }

  /// animate & remove item at index
  void remove(List<int> indexes) {
    if (!mounted) {
      return;
    }
    _gridController.remove(indexes, commit);
  }

  /// animate & remove data
  ///
  /// useful when you want to implement drag to remove
  void removeData(dynamic data) {
    if (!mounted) {
      return;
    }
    _gridController.removeData(data, commit);
  }

  /// upload all uploadable file
  Future<List<UploadableFormeFile>> upload(
      {bool retry = false,
      bool onlyRetry = false,
      List<FormeFile>? files}) async {
    final List<UploadableFormeFile> uploadables = _findUploadableFile(value);
    final List<Future> futures = [];
    for (final UploadableFormeFile element in uploadables) {
      final FormeFileUploadController uploadController =
          _createFileUploadController(element);
      if (uploadController.isUploadError) {
        if (onlyRetry || retry) {
          uploadController.reset();
          futures.add(uploadController.upload());
        }
      } else {
        if (!onlyRetry) {
          futures.add(uploadController.upload());
        }
      }
    }
    if (futures.isEmpty) {
      return [];
    }
    await Future.wait<dynamic>(futures);
    return uploadables;
  }

  void cancelUpload([List<FormeFile>? files]) {
    for (final UploadableFormeFile element in _findUploadableFile(files)) {
      _createFileUploadController(element).cancel();
    }
  }

  FormeFileUploadController _createFileUploadController(
      UploadableFormeFile file) {
    return file._createUploadController(
        widget.onUploadSuccess == null
            ? null
            : (dynamic result) {
                widget.onUploadSuccess?.call(file, result);
              },
        widget.onUploadFail == null
            ? null
            : (error, trace) {
                widget.onUploadFail?.call(file, error, trace);
              });
  }

  List<UploadableFormeFile> _findUploadableFile(List<FormeFile>? files) {
    Iterable<UploadableFormeFile> it = value.whereType<UploadableFormeFile>();
    if (files != null) {
      it = it.where((element) => files.contains(element));
    }
    return it.toList();
  }

  Widget _errorBuilder(BuildContext context, FormeFile item, VoidCallback retry,
      Object error, StackTrace? trace) {
    return widget.imageLoadingErrorBuilder
            ?.call(context, item, retry, error, trace) ??
        Container(
          color: Colors.black.withOpacity(0.4),
          child: Center(
            child: IconButton(
              onPressed: retry,
              icon: const Icon(Icons.broken_image_rounded),
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        );
  }

  Widget _thumbnailLoadingBuilder(
    BuildContext context,
    FormeFile item,
  ) {
    return widget.thumbnailLoadingBuilder?.call(context, item) ??
        const Center(
          child: CircularProgressIndicator(),
        );
  }

  Widget _thumbnail(ImageProvider provider, FormeFile item) {
    return Builder(builder: (rootContext) {
      return Image(
        key: item._imageKey,
        image: provider,
        fit: widget.imageFit,
        width: double.infinity,
        height: double.infinity,
        excludeFromSemantics: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (item is! UploadableFormeFile) {
            return child;
          }
          return UploadStack(
            decoration: widget.uploadBackgroundDecoration,
            autoUpload: item.autoUpload,
            controller: _createFileUploadController(item),
            uploadErrorData: widget.uploadErrorIconData,
            uploadErrorIconColor: widget.uploadErrorIconColor,
            uploadIconColor: widget.uploadIconColor,
            uploadIconData: widget.uploadIconData,
            child: child,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          final bool isImageLoaded = loadingProgress == null &&
              ((child is RawImage && child.image != null) ||
                  (child is UploadStack &&
                      (child.child as RawImage).image != null));
          if (widget.imageLoadingBuilder != null) {
            return widget.imageLoadingBuilder!(
                context, item, child, loadingProgress, isImageLoaded);
          }
          if (isImageLoaded) {
            return child;
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrintStack(stackTrace: stackTrace, label: '$error');
          return _errorBuilder(context, item, () {
            provider.evict().then((value) {
              item._imageKey = UniqueKey();
              (rootContext as Element).markNeedsBuild();
            });
          }, error, stackTrace);
        },
      );
    });
  }

  Widget _gridItem(
    FormeFile item,
    int index,
  ) {
    final bool readOnly = this.readOnly;
    final Widget thumbnail = Builder(builder: (builderContext) {
      if (item._cache != null) {
        return _thumbnail(item._cache!, item);
      }
      return FutureBuilder<ImageProvider>(
        future: item._thumbnail,
        builder: (context, builder) {
          if (builder.connectionState == ConnectionState.waiting) {
            return _thumbnailLoadingBuilder(context, item);
          } else {
            if (builder.hasError) {
              return _errorBuilder(context, item, () {
                if (mounted) {
                  item._future = null;
                  (builderContext as Element).markNeedsBuild();
                }
              }, builder.error!, builder.stackTrace);
            }
            if (builder.hasData) {
              item._cache = builder.data;
              return _thumbnail(builder.data!, item);
            }
          }
          return const SizedBox.shrink();
        },
      );
    });

    final bool showGridItemRemoveIcon = widget.showGridItemRemoveWidget &&
        (widget.removable == null || widget.removable!(item, index));

    return Stack(
      children: [
        thumbnail,
        if (!readOnly && showGridItemRemoveIcon)
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              highlightColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: widget.gridItemRemoveWidget ??
                  const Icon(
                    Icons.cancel,
                    color: Colors.redAccent,
                  ),
              onTap: () {
                _removeByUserInteractive(item, index);
              },
            ),
          )
      ],
    );
  }

  void insertFiles(List<FormeFile> files) {
    if (!mounted || files.isEmpty) {
      return;
    }

    final List<FormeFile> currentValue =
        (_gridController.currentItems ?? _gridController.value)
            .where((element) => element.value != null)
            .map((e) => e.value!)
            .toList();
    final int num = currentValue.length;
    final int? canInsertNums =
        widget.maximum == null ? null : widget.maximum! - num;
    if (canInsertNums != null && canInsertNums <= 0) {
      return;
    }

    List<FormeFile> needInserts =
        files.where((element) => !currentValue.contains(element)).toList();
    if (needInserts.isEmpty) {
      return;
    }

    if (canInsertNums != null && canInsertNums < needInserts.length) {
      needInserts = needInserts.sublist(0, canInsertNums);
    }

    final List<FormeFile> list = [];
    for (final FormeFile item in needInserts) {
      if (!list.contains(item)) {
        list.add(item);
      }
    }
    _gridController.value = _convert(currentValue..addAll(list));
  }

  int? get _maxInsetableNum =>
      widget.maximum == null ? null : widget.maximum! - value.length;

  Widget _buildFilePicker(FormeFileGridState field) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: readOnly
            ? null
            : () {
                widget.pickFiles.call(this, _maxInsetableNum);
              },
        child: widget.filePickerBuilder?.call(field) ??
            Container(
              color: readOnly
                  ? widget.filePickerDisabledColor ??
                      Theme.of(context).disabledColor
                  : widget.filePickerColor ?? Colors.grey.withOpacity(0.3),
              child: widget.filePickerChild ??
                  const Center(child: Icon(Icons.add)),
            ),
      ),
    );
  }

  DraggableConfiguration<_Item<FormeFile>> _draggableConfiguration() {
    return DraggableConfiguration<_Item<FormeFile>>(
      draggable: (item, index) {
        if (item.value == null) {
          return false;
        }
        return widget.draggable?.call(item.value!, index) ?? true;
      },
      longPressDelay: widget.longPressDelayStartDrag,
      childWhenDraggingBuilder: widget.childWhenDraggingBuilder == null
          ? null
          : (context, item, index, child) {
              return widget.childWhenDraggingBuilder!(
                  context, item.value!, index, child);
            },
      feedbackBuilder: widget.feedbackBuilder == null
          ? null
          : (context, item, index, child, size) {
              return widget.feedbackBuilder!(
                  context, item.value!, index, child, size);
            },
      onDragStart: (int index) {
        _draggingNotifer.value = true;
      },
      onDragEnd: (int index) {
        _draggingNotifer.value = false;
      },
    );
  }

  void _onAccept(List<_Item<FormeFile>> value) {
    _gridController.value = value;
  }
}

@immutable
class _Item<T> {
  final T? value;
  const _Item(this.value);

  const _Item.empty() : value = null;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    return other is _Item<T> && other.value == value;
  }
}

abstract class FormeFile {
  Future<ImageProvider> get thumbnail;
  Future<ImageProvider> get currentThumbnail => _thumbnail;
  ImageProvider? get currentLoadedThumbnail => _cache;

  Future<ImageProvider> get _thumbnail => _future ??= thumbnail;
  Future<ImageProvider>? _future;
  Key _imageKey = UniqueKey();
  ImageProvider? _cache;
}

abstract class UploadableFormeFile<T> extends FormeFile {
  Future<T> upload();
  Future<void> cancelUpload() async {}

  /// notify file upload progress
  void progress(Widget? widget) {
    _uploadController?.progress(widget);
  }

  bool get autoUpload => false;

  bool get isUploading => _uploadController?.isUploading ?? false;
  bool get isUploadSuccess => _uploadController?.isUploadSuccess ?? false;
  T? get uploadResult => _uploadController?.uploadResult;
  bool get isUploadError => _uploadController?.isUploadError ?? false;
  Object? get uploadError => _uploadController?.error;
  StackTrace? get uploadErrorStackTrace => _uploadController?.stackTrace;

  FormeFileUploadController<T>? _uploadController;
  FormeFileUploadController<T> _createUploadController(
      Function(T result)? onUploadSuccess,
      Function(Object error, StackTrace? trace)? onUploadFail) {
    return _uploadController ??= FormeFileUploadController<T>(
        upload, cancelUpload, onUploadSuccess, onUploadFail);
  }
}
