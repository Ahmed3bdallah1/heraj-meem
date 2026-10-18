import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../config/app_font.dart';
import '../../../../../main.dart';
import '../../../../../ui/ui.dart';
import '../../domain/use_case/create_story_use_case.dart';
import '../../../../../features/profile/domain/use_cases/upload_file_use_case.dart';

class AddStoryScreen extends ConsumerStatefulWidget {
  const AddStoryScreen({super.key});

  @override
  ConsumerState<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends ConsumerState<AddStoryScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final PageController _pageController = PageController();
  List<String> _selectedMediaUrls = [];
  bool _isUploading = false;
  bool _isCreating = false;
  int _currentPage = 0;
  int? _draggedIndex;
  Offset? _dragPosition;
  Offset? _initialDragPosition;
  bool _isReordering = false;

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isEmpty) return;

      if (!mounted) return;

      setState(() {
        _isUploading = true;
      });

      UIHelper.showGlobalSnackBar(
        text: 'Uploading images...'.tr,
        color: AppColor.primary,
      );

      final uploadFileUseCase = getIt<UploadFileUseCase>();
      final List<String> uploadedUrls = [];

      for (var xFile in images) {
        try {
          final file = File(xFile.path);
          final result = await uploadFileUseCase.call(file);
          result.fold(
            (failure) {
              if (mounted) {
                UIHelper.showGlobalSnackBar(
                  text: '${"Failed to upload image:".tr} ${xFile.name}',
                  color: AppColor.danger,
                );
              }
            },
            (uploadFileModel) {
              uploadedUrls.add(uploadFileModel.filePath);
            },
          );
        } catch (e) {
          if (mounted) {
            UIHelper.showGlobalSnackBar(
              text: '${"Error uploading:".tr} ${e.toString()}',
              color: AppColor.danger,
            );
          }
        }
      }

      if (mounted) {
        setState(() {
          _selectedMediaUrls.addAll(uploadedUrls);
          _isUploading = false;
        });

        if (uploadedUrls.isNotEmpty) {
          UIHelper.showGlobalSnackBar(
            text:
                '${uploadedUrls.length} ${"image(s) uploaded successfully".tr}',
            color: AppColor.green,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        UIHelper.showGlobalSnackBar(
          text: '${"Error picking images:".tr} ${e.toString()}',
          color: AppColor.danger,
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video == null) return;

      if (!mounted) return;

      setState(() {
        _isUploading = true;
      });

      UIHelper.showGlobalSnackBar(
        text: 'Uploading video...'.tr,
        color: AppColor.primary,
      );

      final uploadFileUseCase = getIt<UploadFileUseCase>();
      final file = File(video.path);

      final result = await uploadFileUseCase.call(file);
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _isUploading = false;
            });
            UIHelper.showGlobalSnackBar(
              text: 'Failed to upload video: ${failure.message}'.tr,
              color: AppColor.danger,
            );
          }
        },
        (uploadFileModel) {
          if (mounted) {
            setState(() {
              _selectedMediaUrls.add(uploadFileModel.filePath);
              _isUploading = false;
            });
            UIHelper.showGlobalSnackBar(
              text: 'Video uploaded successfully'.tr,
              color: AppColor.green,
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        UIHelper.showGlobalSnackBar(
          text: '${"Error picking video:".tr} ${e.toString()}',
          color: AppColor.danger,
        );
      }
    }
  }

  Future<void> _createStory() async {
    if (_selectedMediaUrls.isEmpty) {
      UIHelper.showGlobalSnackBar(
        text: 'Please select at least one image or video'.tr,
        color: AppColor.danger,
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final media = _selectedMediaUrls.map((url) {
        final isVideo = url.toLowerCase().contains('.mp4') ||
            url.toLowerCase().contains('.mov') ||
            url.toLowerCase().contains('.avi') ||
            url.toLowerCase().contains('.webm');

        return {
          'url': url,
          'type': isVideo ? 'video' : 'image',
        };
      }).toList();

      final createStoryUseCase = getIt<CreateStoryUseCase>();
      final result = await createStoryUseCase.call(media);

      if (!mounted) return;

      result.fold(
        (failure) {
          UIHelper.showGlobalSnackBar(
            text: failure.message,
            color: AppColor.danger,
          );
        },
        (_) {
          UIHelper.showGlobalSnackBar(
            text: 'Story created successfully!'.tr,
            color: AppColor.green,
          );
          // Navigate back
          Navigator.pop(context);
        },
      );
    } catch (e) {
      if (mounted) {
        UIHelper.showGlobalSnackBar(
          text: '${"Error creating story:".tr} ${e.toString()}',
          color: AppColor.danger,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMediaUrls.removeAt(index);
      if (_currentPage >= _selectedMediaUrls.length &&
          _selectedMediaUrls.isNotEmpty) {
        _currentPage = _selectedMediaUrls.length - 1;
      } else if (_selectedMediaUrls.isEmpty) {
        _currentPage = 0;
      }
      if (_pageController.hasClients && _selectedMediaUrls.isNotEmpty) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _reorderMedia(int oldIndex, int newIndex) {
    if (oldIndex == newIndex || _isReordering) return;

    _isReordering = true;

    final item = _selectedMediaUrls.removeAt(oldIndex);
    _selectedMediaUrls.insert(newIndex, item);

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _isReordering = false;
      }
    });
  }

  void _resetDragState() {
    if (_draggedIndex == null) return;

    setState(() {
      _draggedIndex = null;
      _dragPosition = null;
      _initialDragPosition = null;
    });
  }

  Future<bool?> _showDiscardDialog(BuildContext context) async {
    bool? result;

    await AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Discard Story?'.tr,
      desc:
          'Are you sure you want to discard this story? All selected media will be lost.'
              .tr,
      btnCancelText: 'Cancel'.tr,
      btnOkText: 'Discard'.tr,
      btnCancelOnPress: () {
        result = false;
      },
      btnOkOnPress: () {
        result = true;
      },
      btnOkColor: Colors.red,
      btnCancelColor: AppColor.grey2,
    ).show();

    return result;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedMediaUrls.isEmpty,
      onPopInvokedWithResult: (didPop,_) async {
        if (didPop) return;

        if (_selectedMediaUrls.isNotEmpty) {
          final shouldPop = await _showDiscardDialog(context);
          if (shouldPop == true && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'Add Story'.tr,
            style: AppFont.font18W700Black,
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () async {
              if (_selectedMediaUrls.isNotEmpty) {
                final shouldPop = await _showDiscardDialog(context);
                if (shouldPop == true && mounted) {
                  Navigator.pop(context);
                }
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: _selectedMediaUrls.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 80,
                            color: AppColor.primary.withAlpha(200),
                          ),
                          const Gap(20),
                          Text(
                            'Select Images or Videos'.tr,
                            style: AppFont.font16W600NearlyWhite,
                            textAlign: TextAlign.center,
                          ),
                          const Gap(12),
                          Text(
                            'Choose images or videos to add to your story'.tr,
                            style: AppFont.font14W500Grey2,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          physics: _draggedIndex == null
                              ? const PageScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
                          itemCount: _selectedMediaUrls.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final url = _selectedMediaUrls[index];
                            final isVideo =
                                url.toLowerCase().contains('.mp4') ||
                                    url.toLowerCase().contains('.mov') ||
                                    url.toLowerCase().contains('.avi') ||
                                    url.toLowerCase().contains('.webm');
                            final isDragging = _draggedIndex == index;

                            return GestureDetector(
                              onLongPressStart: (details) {
                                setState(() {
                                  _draggedIndex = index;
                                  _currentPage = index;
                                  _dragPosition = details.localPosition;
                                  _initialDragPosition = details.localPosition;
                                });
                              },
                              onLongPressMoveUpdate: (details) {
                                if (_isReordering) return;

                                setState(() {
                                  _dragPosition = details.localPosition;
                                });

                                if (_initialDragPosition != null &&
                                    _draggedIndex != null &&
                                    !_isReordering) {
                                  final screenWidth =
                                      MediaQuery.of(context).size.width;
                                  final dragDeltaX = _dragPosition!.dx -
                                      _initialDragPosition!.dx;
                                  final threshold = screenWidth * 0.3;

                                  if (dragDeltaX < -threshold &&
                                      _draggedIndex! > 0) {
                                    final newIndex = _draggedIndex! - 1;
                                    _reorderMedia(_draggedIndex!, newIndex);
                                    _draggedIndex = newIndex;
                                    _initialDragPosition = _dragPosition;
                                  } else if (dragDeltaX > threshold &&
                                      _draggedIndex! <
                                          _selectedMediaUrls.length - 1) {
                                    final newIndex = _draggedIndex! + 1;
                                    _reorderMedia(_draggedIndex!, newIndex);
                                    _draggedIndex = newIndex;
                                    _initialDragPosition = _dragPosition;
                                  }
                                }
                              },
                              onLongPressEnd: (details) {
                                final screenHeight =
                                    MediaQuery.of(context).size.height;
                                final bottomZoneHeight =
                                    MediaQuery.of(context).padding.bottom + 140;

                                if (details.localPosition.dy >
                                    screenHeight - bottomZoneHeight) {
                                  _removeMedia(index);
                                } else if (_draggedIndex != null) {
                                  _currentPage = _draggedIndex!;
                                  if (_pageController.hasClients) {
                                    _pageController.jumpToPage(_currentPage);
                                  }
                                }

                                _resetDragState();
                              },
                              onLongPressCancel: () {
                                _resetDragState();
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Opacity(
                                    opacity: isDragging ? 0.3 : 1.0,
                                    child: isVideo
                                        ? Container(
                                            color: Colors.black,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.video_library,
                                                    size: 60,
                                                    color: Colors.white
                                                        .withAlpha(200),
                                                  ),
                                                  const Gap(12),
                                                  Text(
                                                    'Video'.tr,
                                                    style: AppFont
                                                        .font16W600Black
                                                        .copyWith(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Image.network(
                                            url,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: AppColor.grey1,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.image,
                                                    size: 60,
                                                    color: AppColor.grey2,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                  if (!isDragging)
                                    PositionedDirectional(
                                      top: 16,
                                      end: 16,
                                      child: GestureDetector(
                                        onTap: () => _removeMedia(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    Colors.black.withAlpha(100),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        if (_draggedIndex != null && _dragPosition != null)
                          Positioned(
                            left: _dragPosition!.dx - 100,
                            top: _dragPosition!.dy - 100,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                if (_isReordering) return;

                                setState(() {
                                  _dragPosition = details.localPosition;
                                });

                                if (_initialDragPosition != null &&
                                    _draggedIndex != null &&
                                    !_isReordering) {
                                  final screenWidth =
                                      MediaQuery.of(context).size.width;
                                  final dragDeltaX = _dragPosition!.dx -
                                      _initialDragPosition!.dx;
                                  final threshold = screenWidth * 0.3;

                                  if (dragDeltaX < -threshold &&
                                      _draggedIndex! > 0) {
                                    final newIndex = _draggedIndex! - 1;
                                    _reorderMedia(_draggedIndex!, newIndex);
                                    _draggedIndex = newIndex;
                                    _initialDragPosition = _dragPosition;
                                  } else if (dragDeltaX > threshold &&
                                      _draggedIndex! <
                                          _selectedMediaUrls.length - 1) {
                                    final newIndex = _draggedIndex! + 1;
                                    _reorderMedia(_draggedIndex!, newIndex);
                                    _draggedIndex = newIndex;
                                    _initialDragPosition = _dragPosition;
                                  }
                                }
                              },
                              onPanEnd: (details) {
                                final screenHeight =
                                    MediaQuery.of(context).size.height;
                                final bottomZoneHeight =
                                    MediaQuery.of(context).padding.bottom + 140;

                                if (_dragPosition != null &&
                                    _dragPosition!.dy >
                                        screenHeight - bottomZoneHeight) {
                                  if (_draggedIndex != null) {
                                    _removeMedia(_draggedIndex!);
                                  }
                                } else if (_draggedIndex != null) {
                                  _currentPage = _draggedIndex!;
                                  if (_pageController.hasClients) {
                                    _pageController.jumpToPage(_currentPage);
                                  }
                                }

                                _resetDragState();
                              },
                              child: Transform.scale(
                                scale: 1.2,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(200),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _selectedMediaUrls[_draggedIndex!]
                                                .toLowerCase()
                                                .contains('.mp4') ||
                                            _selectedMediaUrls[_draggedIndex!]
                                                .toLowerCase()
                                                .contains('.mov') ||
                                            _selectedMediaUrls[_draggedIndex!]
                                                .toLowerCase()
                                                .contains('.avi') ||
                                            _selectedMediaUrls[_draggedIndex!]
                                                .toLowerCase()
                                                .contains('.webm')
                                        ? Container(
                                            color: Colors.black,
                                            child: const Icon(
                                              Icons.video_library,
                                              color: Colors.white,
                                              size: 60,
                                            ),
                                          )
                                        : Image.network(
                                            _selectedMediaUrls[_draggedIndex!],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: AppColor.grey1,
                                                child: const Icon(Icons.image),
                                              );
                                            },
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_selectedMediaUrls.length > 1)
                          PositionedDirectional(
                            top: 16,
                            start: 16,
                            end: 60,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(150),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_currentPage + 1} / ${_selectedMediaUrls.length}',
                                style: AppFont.font14W600Black.copyWith(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            // Bottom buttons section - hide when dragging
            if (_draggedIndex == null)
              PositionedDirectional(
                bottom: MediaQuery.of(context).padding.bottom + 10,
                start: 16,
                end: 16,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: CustomFilledButton(
                        isValid: !(_isUploading || _isCreating),
                        onPressed:
                            _isUploading || _isCreating ? null : _pickImages,
                        widget: const Icon(Icons.photo_library),
                        text: 'Select Images'.tr,
                      ),
                    ),
                    const Gap(12),
                    SizedBox(
                      width: double.infinity,
                      child: CustomFilledButton(
                        isValid: !(_isUploading || _isCreating),
                        onPressed: (_isUploading ||
                                _isCreating ||
                                _selectedMediaUrls.isEmpty)
                            ? null
                            : _createStory,
                        color: AppColor.green,
                        widget: const Icon(Icons.upload),
                        text: 'Create Story'.tr,
                      ),
                    ),
                  ],
                ),
              ),
            // Delete zone - show when dragging (replaces buttons)
            if (_draggedIndex != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).padding.bottom + 140,
                  decoration: BoxDecoration(
                    color: _dragPosition != null &&
                            _dragPosition!.dy >
                                MediaQuery.of(context).size.height -
                                    (MediaQuery.of(context).padding.bottom +
                                        140)
                        ? Colors.red.withAlpha(180)
                        : Colors.black.withAlpha(200),
                    border: Border(
                      top: BorderSide(
                        color: _dragPosition != null &&
                                _dragPosition!.dy >
                                    MediaQuery.of(context).size.height -
                                        (MediaQuery.of(context).padding.bottom +
                                            140)
                            ? Colors.red
                            : AppColor.grey1.withAlpha(100),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 50,
                          color: _dragPosition != null &&
                                  _dragPosition!.dy >
                                      MediaQuery.of(context).size.height -
                                          (MediaQuery.of(context)
                                                  .padding
                                                  .bottom +
                                              140)
                              ? Colors.white
                              : Colors.white.withAlpha(120),
                        ),
                        const Gap(8),
                        Text(
                          'Drop here to delete'.tr,
                          style: AppFont.font16W600Black.copyWith(
                            color: _dragPosition != null &&
                                    _dragPosition!.dy >
                                        MediaQuery.of(context).size.height -
                                            (MediaQuery.of(context)
                                                    .padding
                                                    .bottom +
                                                140)
                                ? Colors.white
                                : Colors.white.withAlpha(120),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
