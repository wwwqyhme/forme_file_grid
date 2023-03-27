import 'package:flutter/cupertino.dart';

import 'forme_upload_state_controller.dart';
import 'upload_progress_controller.dart';

class FormeFileUploadController<T> {
  final Future<T> Function() _upload;
  final Future<void> Function() _cancel;
  final void Function(T result)? _onUploadSuccess;
  final void Function(Object error, StackTrace? trace)? _onUploadFail;

  FormeFileUploadController(
      this._upload, this._cancel, this._onUploadSuccess, this._onUploadFail);

  Object? error;
  StackTrace? stackTrace;

  bool get isUploadError => error != null;
  bool get isUploadSuccess => _uploadSuccess;
  bool get isUploadComplete => isUploadSuccess || isUploadError;
  T? get uploadResult => _result;
  bool get isUploading => _uploading;
  Widget? get progressValue => _progressValue;

  void progress(Widget? value) {
    _progressValue = value;
    _updateProgress(value);
  }

  void bindController(
    FormeFileUploadProgressController controller,
    FormeUploadStateController stateController,
  ) {
    _progressControllers.add(controller);
    _stateControllers.add(stateController);
  }

  void unbindController(
    FormeFileUploadProgressController controller,
    FormeUploadStateController stateController,
  ) {
    _progressControllers.remove(controller);
    _stateControllers.remove(stateController);
  }

  Future<T?> upload() async {
    if (_uploadFuture != null) {
      return _uploadFuture!;
    }
    _updateState(UploadState.uploading);
    _uploading = true;
    try {
      final T uploadResult = await (_uploadFuture ??= _upload());
      _result = uploadResult;
      _uploadSuccess = true;
      _uploading = false;
      _updateState(UploadState.success);
      _onUploadSuccess?.call(uploadResult);
      return uploadResult;
    } catch (e, trace) {
      debugPrintStack(stackTrace: trace);
      _uploading = false;
      error = e;
      stackTrace = trace;
      _updateState(UploadState.error);
      _onUploadFail?.call(e, trace);
      return null;
    }
  }

  /// cancel upload
  Future cancel() async {
    if (isUploading) {
      reset();
      await _cancel();
    }
  }

  void reset() {
    _result = null;
    _updateProgress(null);
    _updateState(UploadState.waiting);
    _uploading = false;
    _progressValue = null;
    _uploadSuccess = false;
    _uploadFuture = null;
    error = null;
    stackTrace = null;
  }

  void _updateState(UploadState state) {
    for (final controller in _stateControllers) {
      controller.value = state;
    }
  }

  void _updateProgress(Widget? value) {
    for (final controller in _progressControllers) {
      controller.value = value;
    }
  }

  T? _result;
  final List<FormeFileUploadProgressController> _progressControllers = [];
  final List<FormeUploadStateController> _stateControllers = [];
  bool _uploading = false;
  Widget? _progressValue;
  bool _uploadSuccess = false;
  Future<T>? _uploadFuture;
}
