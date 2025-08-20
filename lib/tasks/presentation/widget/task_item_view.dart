import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../components/widgets.dart';
import '../../../routes/pages.dart';
import '../../../utils/color_palette.dart';
import '../../../utils/font_sizes.dart';
import '../../../utils/util.dart';
import '../../data/local/model/task_model.dart';
import '../bloc/tasks_bloc.dart';

class TaskItemView extends StatefulWidget {
  final TaskModel taskModel;
  const TaskItemView({super.key, required this.taskModel});

  @override
  State<TaskItemView> createState() => _TaskItemViewState();
}

class _TaskItemViewState extends State<TaskItemView> {
  @override
  Widget build(BuildContext context) {
    final bool isCompleted = widget.taskModel.completed;
    final bool isOverdue = widget.taskModel.stopDateTime != null &&
        widget.taskModel.stopDateTime!.isBefore(DateTime.now()) && !isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue ? kRed.withOpacity(0.3) : kGrey3.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom checkbox with better visual feedback
              GestureDetector(
                onTap: () {
                  var taskModel = TaskModel(
                    id: widget.taskModel.id,
                    title: widget.taskModel.title,
                    description: widget.taskModel.description,
                    completed: !widget.taskModel.completed,
                    startDateTime: widget.taskModel.startDateTime,
                    stopDateTime: widget.taskModel.stopDateTime,
                  );
                  context.read<TasksBloc>().add(
                      UpdateTaskEvent(taskModel: taskModel));
                },
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    color: isCompleted ? kPrimaryColor : Colors.transparent,
                    border: Border.all(
                      color: isCompleted ? kPrimaryColor : kGrey2,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isCompleted
                      ? const Icon(
                    Icons.check,
                    color: kWhiteColor,
                    size: 16,
                  )
                      : null,
                ),
              ),

              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Priority indicator (if overdue)
                        if (isOverdue)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: kRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: buildText(
                              'OVERDUE',
                              kRed,
                              10,
                              FontWeight.w600,
                              TextAlign.start,
                              TextOverflow.clip,
                            ),
                          ),

                        // Task title
                        Expanded(
                          child: buildText(
                            widget.taskModel.title,
                            isCompleted ? kGrey2 : kBlackColor,
                            textMedium,
                            FontWeight.w600,
                            TextAlign.start,
                            TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Task description
                    if (widget.taskModel.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: buildText(
                          widget.taskModel.description,
                          isCompleted ? kGrey2.withOpacity(0.7) : kGrey1,
                          textSmall,
                          FontWeight.normal,
                          TextAlign.start,
                          TextOverflow.ellipsis,
                        ),
                      ),

                    // Date range with improved styling
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? kRed.withOpacity(0.05)
                            : isCompleted
                            ? kGrey3.withOpacity(0.3)
                            : kPrimaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/svgs/calender.svg',
                            width: 14,
                            color: isOverdue
                                ? kRed
                                : isCompleted
                                ? kGrey2
                                : kPrimaryColor,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: buildText(
                              '${formatDate(dateTime: widget.taskModel.startDateTime.toString())} - ${formatDate(dateTime: widget.taskModel.stopDateTime.toString())}',
                              isOverdue
                                  ? kRed
                                  : isCompleted
                                  ? kGrey2
                                  : kBlackColor,
                              textTiny,
                              FontWeight.w500,
                              TextAlign.start,
                              TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Menu button with better touch target
              PopupMenuButton<int>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 160,
                  maxWidth: 200,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: kWhiteColor,
                elevation: 8,
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      Navigator.pushNamed(context, Pages.updateTask,
                          arguments: widget.taskModel);
                      break;
                    case 1:
                    // Show confirmation dialog before deleting
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: buildText('Delete Task', kBlackColor,
                                textMedium, FontWeight.w600, TextAlign.start,
                                TextOverflow.clip),
                            content: buildText(
                                'Are you sure you want to delete this task?',
                                kBlackColor, textSmall, FontWeight.normal,
                                TextAlign.start, TextOverflow.clip),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: buildText('Cancel', kGrey1, textSmall,
                                    FontWeight.w500, TextAlign.center,
                                    TextOverflow.clip),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.read<TasksBloc>().add(
                                      DeleteTaskEvent(taskModel: widget.taskModel));
                                },
                                child: buildText('Delete', kRed, textSmall,
                                    FontWeight.w600, TextAlign.center,
                                    TextOverflow.clip),
                              ),
                            ],
                          );
                        },
                      );
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<int>(
                      value: 0,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: SvgPicture.asset(
                              'assets/svgs/edit.svg',
                              width: 16,
                              color: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          buildText('Edit task', kBlackColor, textSmall,
                              FontWeight.w500, TextAlign.start,
                              TextOverflow.clip),
                        ],
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: SvgPicture.asset(
                              'assets/svgs/delete.svg',
                              width: 16,
                              color: kRed,
                            ),
                          ),
                          const SizedBox(width: 12),
                          buildText('Delete task', kRed, textSmall,
                              FontWeight.w500, TextAlign.start,
                              TextOverflow.clip),
                        ],
                      ),
                    ),
                  ];
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kGrey3.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    'assets/svgs/vertical_menu.svg',
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}