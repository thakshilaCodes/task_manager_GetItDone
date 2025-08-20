import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/build_text_field.dart';
import '../../../components/widgets.dart';
import '../../../routes/pages.dart';
import '../../../utils/color_palette.dart';
import '../../../utils/font_sizes.dart';
import '../../../utils/shared_preferences_helper.dart';
import '../../../utils/util.dart';
import '../bloc/tasks_bloc.dart';
import '../widget/task_item_view.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TextEditingController searchController = TextEditingController();
  String userName = 'User'; // Default name
  bool _isLoadingName = true;

  @override
  void initState() {
    super.initState();
    print('TasksScreen: Initializing');
    _loadUserName();
    context.read<TasksBloc>().add(FetchTaskEvent());
  }

  Future<void> _loadUserName() async {
    print('TasksScreen: _loadUserName started');

    try {
      await Future.delayed(const Duration(milliseconds: 100));

      await SharedPreferencesHelper.debugPrintAllValues();

      final name = await SharedPreferencesHelper.getUserName();
      print('TasksScreen: Retrieved name from helper: "$name"');

      final prefs = await SharedPreferences.getInstance();
      final directName = prefs.getString('user_name');
      print('TasksScreen: Direct SharedPreferences name: "$directName"');

      if (mounted) {
        setState(() {
          userName = name ?? directName ?? 'User';
          _isLoadingName = false;
        });
        print('TasksScreen: Set userName to: "$userName"');
      }
    } catch (e) {
      print('TasksScreen: Error loading name: $e');
      if (mounted) {
        setState(() {
          userName = 'User';
          _isLoadingName = false;
        });
      }
    }
  }

  Future<void> _reloadUserName() async {
    print('TasksScreen: Force reloading user name');
    setState(() {
      _isLoadingName = true;
    });
    await _loadUserName();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: kBlackColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 20),
            child: Container(
              decoration: BoxDecoration(
                color: kBlackColor,
                border: Border(
                  bottom: BorderSide(
                    color: kWhiteColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      // Profile section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildText(
                              _getGreeting(),
                              kWhiteColor.withOpacity(0.7),
                              textSmall,
                              FontWeight.w400,
                              TextAlign.start,
                              TextOverflow.clip,
                            ),
                            const SizedBox(height: 2),
                            _isLoadingName
                                ? Container(
                              width: 80,
                              height: 18,
                              decoration: BoxDecoration(
                                color: kWhiteColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )
                                : GestureDetector(
                              onLongPress: _reloadUserName, // Long press to reload
                              child: buildText(
                                'Hi $userName',
                                kWhiteColor,
                                textMedium + 2,
                                FontWeight.w700,
                                TextAlign.start,
                                TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Debug button (remove in production)
                      if (true) // Set to false in production
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () async {
                              await SharedPreferencesHelper.debugPrintAllValues();
                              final name = await SharedPreferencesHelper.getUserName();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Debug: Current name is "$name", Display: "$userName"'),
                                    duration: const Duration(seconds: 3),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.bug_report,
                                size: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),

                      // Profile avatar
                      GestureDetector(
                        onTap: _isLoadingName ? null : () {
                          _showEditNameDialog();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: kPrimaryColor.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: _isLoadingName
                                ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  kPrimaryColor.withOpacity(0.7),
                                ),
                              ),
                            )
                                : buildText(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                              kWhiteColor,
                              textMedium,
                              FontWeight.w700,
                              TextAlign.center,
                              TextOverflow.clip,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Filter button with dark theme
                      PopupMenuButton<int>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 8,
                        color: Color(0xFF2C2C2C),
                        onSelected: (value) {
                          switch (value) {
                            case 0:
                              context.read<TasksBloc>().add(SortTaskEvent(sortOption: 0));
                              break;
                            case 1:
                              context.read<TasksBloc>().add(SortTaskEvent(sortOption: 1));
                              break;
                            case 2:
                              context.read<TasksBloc>().add(SortTaskEvent(sortOption: 2));
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem<int>(
                              value: 0,
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/svgs/calender.svg',
                                    width: 15,
                                    colorFilter: ColorFilter.mode(
                                      kWhiteColor,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  buildText(
                                    'Sort by date',
                                    kWhiteColor,
                                    textSmall,
                                    FontWeight.normal,
                                    TextAlign.start,
                                    TextOverflow.clip,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/svgs/task_checked.svg',
                                    width: 15,
                                    colorFilter: ColorFilter.mode(
                                      kWhiteColor,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  buildText(
                                    'Completed tasks',
                                    kWhiteColor,
                                    textSmall,
                                    FontWeight.normal,
                                    TextAlign.start,
                                    TextOverflow.clip,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 2,
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/svgs/task.svg',
                                    width: 15,
                                    colorFilter: ColorFilter.mode(
                                      kWhiteColor,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  buildText(
                                    'Pending tasks',
                                    kWhiteColor,
                                    textSmall,
                                    FontWeight.normal,
                                    TextAlign.start,
                                    TextOverflow.clip,
                                  ),
                                ],
                              ),
                            ),
                          ];
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kWhiteColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: kWhiteColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: SvgPicture.asset(
                              'assets/svgs/filter.svg',
                              colorFilter: ColorFilter.mode(
                                kWhiteColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: BlocConsumer<TasksBloc, TasksState>(
                listener: (context, state) {
                  if (state is LoadTaskFailure) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(getSnackBar(state.error, kRed));
                  }

                  if (state is AddTaskFailure || state is UpdateTaskFailure) {
                    context.read<TasksBloc>().add(FetchTaskEvent());
                  }
                },
                builder: (context, state) {
                  if (state is TasksLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                      ),
                    );
                  }

                  if (state is LoadTaskFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: kRed,
                          ),
                          const SizedBox(height: 16),
                          buildText(
                            'Something went wrong',
                            kWhiteColor,
                            textMedium,
                            FontWeight.w600,
                            TextAlign.center,
                            TextOverflow.clip,
                          ),
                          const SizedBox(height: 8),
                          buildText(
                            state.error,
                            kWhiteColor.withOpacity(0.7),
                            textSmall,
                            FontWeight.normal,
                            TextAlign.center,
                            TextOverflow.clip,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: kWhiteColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              context.read<TasksBloc>().add(FetchTaskEvent());
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.refresh, size: 20),
                                const SizedBox(width: 8),
                                buildText(
                                  'Retry',
                                  kWhiteColor,
                                  textSmall,
                                  FontWeight.w600,
                                  TextAlign.center,
                                  TextOverflow.clip,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is FetchTasksSuccess) {
                    return state.tasks.isNotEmpty || state.isSearching
                        ? Column(
                      children: [
                        // Search field with dark theme
                        Container(
                          decoration: BoxDecoration(
                            color: kWhiteColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: kWhiteColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: BuildTextField(
                            hint: "Search recent task",
                            controller: searchController,
                            inputType: TextInputType.text,
                            prefixIcon: Icon(
                              Icons.search,
                              color: kWhiteColor.withOpacity(0.7),
                            ),
                            fillColor: Colors.transparent,
                            onChange: (value) {
                              context.read<TasksBloc>().add(
                                  SearchTaskEvent(keywords: value));
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tasks header
                        Row(
                          children: [
                            buildText(
                              'Your Tasks',
                              kWhiteColor,
                              textMedium,
                              FontWeight.w600,
                              TextAlign.start,
                              TextOverflow.clip,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: buildText(
                                '${state.tasks.length}',
                                kWhiteColor,
                                textTiny,
                                FontWeight.w600,
                                TextAlign.center,
                                TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Expanded(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: state.tasks.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: kWhiteColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: kWhiteColor.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: TaskItemView(
                                  taskModel: state.tasks[index],
                                ),
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return const SizedBox(height: 12);
                            },
                          ),
                        ),
                      ],
                    )
                        : Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: kWhiteColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kWhiteColor.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.task_alt,
                              size: 64,
                              color: kWhiteColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          buildText(
                            'Schedule your tasks',
                            kWhiteColor,
                            textBold,
                            FontWeight.w600,
                            TextAlign.center,
                            TextOverflow.clip,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: buildText(
                              'Manage your task schedule easily\nand efficiently',
                              kWhiteColor.withOpacity(0.7),
                              textSmall,
                              FontWeight.normal,
                              TextAlign.center,
                              TextOverflow.clip,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: kWhiteColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, Pages.createNewTask);
                            },
                            icon: const Icon(Icons.add, size: 20),
                            label: buildText(
                              'Create First Task',
                              kWhiteColor,
                              textSmall,
                              FontWeight.w600,
                              TextAlign.center,
                              TextOverflow.clip,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: kPrimaryColor,
            foregroundColor: kWhiteColor,
            elevation: 6,
            onPressed: () {
              Navigator.pushNamed(context, Pages.createNewTask);
            },
            icon: const Icon(Icons.add_circle, size: 24),
            label: buildText(
              'New Task',
              kWhiteColor,
              textSmall,
              FontWeight.w600,
              TextAlign.center,
              TextOverflow.clip,
            ),
          ),
        ),
      ),
    );
  }

  // Dialog to edit user name
  void _showEditNameDialog() {
    final TextEditingController editController = TextEditingController();
    editController.text = userName;
    bool isLoading = false;
    bool hasError = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Color(0xFF2C2C2C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.edit, color: kPrimaryColor, size: 24),
                  const SizedBox(width: 8),
                  buildText(
                    'Edit Name',
                    kWhiteColor,
                    textMedium,
                    FontWeight.w600,
                    TextAlign.start,
                    TextOverflow.clip,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildText(
                    'Update your display name',
                    kWhiteColor.withOpacity(0.7),
                    textSmall,
                    FontWeight.w400,
                    TextAlign.start,
                    TextOverflow.clip,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: hasError
                          ? Border.all(color: kRed.withOpacity(0.5))
                          : Border.all(color: kWhiteColor.withOpacity(0.2)),
                    ),
                    child: BuildTextField(
                      hint: "Enter your name",
                      controller: editController,
                      inputType: TextInputType.name,
                      fillColor: kWhiteColor.withOpacity(0.1),
                      prefixIcon: Icon(
                        Icons.person,
                        color: kPrimaryColor.withOpacity(0.7),
                        size: 20,
                      ),
                      onChange: (value) {
                        if (hasError && value.trim().length >= 2) {
                          setDialogState(() {
                            hasError = false;
                          });
                        }
                      },
                    ),
                  ),
                  if (hasError) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.error, size: 16, color: kRed),
                        const SizedBox(width: 4),
                        buildText(
                          'Please enter at least 2 characters',
                          kRed,
                          textTiny,
                          FontWeight.w500,
                          TextAlign.start,
                          TextOverflow.clip,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () {
                    Navigator.pop(context);
                  },
                  child: buildText(
                    'Cancel',
                    kWhiteColor.withOpacity(0.7),
                    textSmall,
                    FontWeight.w500,
                    TextAlign.center,
                    TextOverflow.clip,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isLoading ? null : () async {
                    final newName = editController.text.trim();
                    if (newName.isEmpty || newName.length < 2) {
                      setDialogState(() {
                        hasError = true;
                      });
                      return;
                    }

                    setDialogState(() {
                      isLoading = true;
                      hasError = false;
                    });

                    try {
                      print('TasksScreen: Updating name to: "$newName"');
                      final success = await SharedPreferencesHelper.saveUserName(newName);

                      // Verify the save
                      final savedName = await SharedPreferencesHelper.getUserName();
                      print('TasksScreen: Update verification - success: $success, savedName: "$savedName"');

                      if (success && savedName == newName && mounted) {
                        setState(() {
                          userName = newName;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Name updated to $newName'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update name. Success: $success, Saved: $savedName'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    } catch (e) {
                      print('TasksScreen: Error updating name: $e');
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error occurred: $e'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    } finally {
                      setDialogState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(kWhiteColor),
                    ),
                  )
                      : buildText(
                    'Update',
                    kWhiteColor,
                    textSmall,
                    FontWeight.w600,
                    TextAlign.center,
                    TextOverflow.clip,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}