import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../components/custom_app_bar.dart';
import '../../../components/widgets.dart';
import '../../../utils/color_palette.dart';
import '../../../utils/font_sizes.dart';
import '../../../utils/util.dart';
import '../../data/local/model/task_model.dart';
import '../bloc/tasks_bloc.dart';
import '../../../components/build_text_field.dart';

class UpdateTaskScreen extends StatefulWidget {
  final TaskModel taskModel;

  const UpdateTaskScreen({super.key, required this.taskModel});

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  bool _titleError = false;
  bool _dateError = false;
  bool _hasChanges = false;

  _onRangeSelected(DateTime? start, DateTime? end, DateTime focusDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusDay;
      _rangeStart = start;
      _rangeEnd = end;
      _dateError = false;
      _hasChanges = true;
    });
  }

  bool _validateForm() {
    bool isValid = true;

    setState(() {
      _titleError = title.text.trim().isEmpty;
      _dateError = _rangeStart == null || _rangeEnd == null;
    });

    if (_titleError || _dateError) {
      isValid = false;
    }

    return isValid;
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  void initState() {
    title.text = widget.taskModel.title;
    description.text = widget.taskModel.description;
    _selectedDay = _focusedDay;
    _rangeStart = widget.taskModel.startDateTime;
    _rangeEnd = widget.taskModel.stopDateTime;

    // Listen to text changes
    title.addListener(() {
      if (title.text != widget.taskModel.title) {
        setState(() {
          _hasChanges = true;
          if (_titleError) _titleError = false;
        });
      }
    });

    description.addListener(() {
      if (description.text != widget.taskModel.description) {
        setState(() {
          _hasChanges = true;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: kGrey3.withOpacity(0.05),
        appBar: CustomAppBar(
          title: 'Update Task',
          actionWidgets: [
            if (_hasChanges)
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: buildText(
                  'Modified',
                  Colors.orange,
                  textTiny,
                  FontWeight.w600,
                  TextAlign.center,
                  TextOverflow.clip,
                ),
              ),
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: BlocConsumer<TasksBloc, TasksState>(
                listener: (context, state) {
                  if (state is UpdateTaskFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        getSnackBar(state.error, kRed));
                  }
                  if (state is UpdateTaskSuccess) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        getSnackBar('Task updated successfully!', Colors.green));
                  }
                },
                builder: (context, state) {
                  return ListView(
                    children: [
                      // Task status indicator
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.taskModel.completed
                              ? Colors.green.withOpacity(0.1)
                              : kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.taskModel.completed
                                  ? Icons.check_circle
                                  : Icons.schedule,
                              color: widget.taskModel.completed
                                  ? Colors.green
                                  : kPrimaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            buildText(
                              widget.taskModel.completed
                                  ? 'This task is completed'
                                  : 'This task is pending',
                              widget.taskModel.completed
                                  ? Colors.green
                                  : kPrimaryColor,
                              textMedium,
                              FontWeight.w600,
                              TextAlign.start,
                              TextOverflow.clip,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Calendar section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(12),
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
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 20, color: kPrimaryColor),
                                const SizedBox(width: 8),
                                buildText(
                                  'Update Date Range',
                                  kBlackColor,
                                  textMedium,
                                  FontWeight.w600,
                                  TextAlign.start,
                                  TextOverflow.clip,
                                ),
                                if (_dateError) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.error, size: 16, color: kRed),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                            TableCalendar(
                              calendarFormat: _calendarFormat,
                              startingDayOfWeek: StartingDayOfWeek.monday,
                              availableCalendarFormats: const {
                                CalendarFormat.month: 'Month',
                                CalendarFormat.week: 'Week',
                              },
                              rangeSelectionMode: RangeSelectionMode.toggledOn,
                              focusedDay: _focusedDay,
                              firstDay: DateTime.utc(2023, 1, 1),
                              lastDay: DateTime.utc(2030, 1, 1),
                              onPageChanged: (focusDay) {
                                _focusedDay = focusDay;
                              },
                              selectedDayPredicate: (day) =>
                                  isSameDay(_selectedDay, day),
                              rangeStartDay: _rangeStart,
                              rangeEndDay: _rangeEnd,
                              onFormatChanged: (format) {
                                if (_calendarFormat != format) {
                                  setState(() {
                                    _calendarFormat = format;
                                  });
                                }
                              },
                              onRangeSelected: _onRangeSelected,
                              calendarStyle: CalendarStyle(
                                outsideDaysVisible: false,
                                rangeHighlightColor: kPrimaryColor.withOpacity(0.2),
                                rangeStartDecoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  shape: BoxShape.circle,
                                ),
                                rangeEndDecoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  shape: BoxShape.circle,
                                ),
                                todayDecoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Date range display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (_rangeStart != null && _rangeEnd != null)
                              ? kPrimaryColor.withOpacity(0.1)
                              : kGrey3.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: _dateError
                              ? Border.all(color: kRed.withOpacity(0.3))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: (_rangeStart != null && _rangeEnd != null)
                                  ? kPrimaryColor
                                  : kGrey2,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildText(
                                _rangeStart != null && _rangeEnd != null
                                    ? 'Task period: ${formatDate(dateTime: _rangeStart.toString())} - ${formatDate(dateTime: _rangeEnd.toString())}'
                                    : 'Select a date range',
                                (_rangeStart != null && _rangeEnd != null)
                                    ? kPrimaryColor
                                    : kGrey2,
                                textSmall,
                                FontWeight.w500,
                                TextAlign.start,
                                TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Task details section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(12),
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
                              children: [
                                Icon(Icons.edit, size: 20, color: kPrimaryColor),
                                const SizedBox(width: 8),
                                buildText(
                                  'Update Task Details',
                                  kBlackColor,
                                  textMedium,
                                  FontWeight.w600,
                                  TextAlign.start,
                                  TextOverflow.clip,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Title field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    buildText(
                                      'Title',
                                      kBlackColor,
                                      textSmall,
                                      FontWeight.w600,
                                      TextAlign.start,
                                      TextOverflow.clip,
                                    ),
                                    buildText(
                                      ' *',
                                      kRed,
                                      textSmall,
                                      FontWeight.w600,
                                      TextAlign.start,
                                      TextOverflow.clip,
                                    ),
                                    if (_titleError) ...[
                                      const SizedBox(width: 8),
                                      Icon(Icons.error, size: 16, color: kRed),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: _titleError
                                        ? Border.all(color: kRed.withOpacity(0.3))
                                        : null,
                                  ),
                                  child: BuildTextField(
                                    hint: "Task Title",
                                    controller: title,
                                    inputType: TextInputType.text,
                                    fillColor: kWhiteColor,
                                    onChange: (value) {},
                                  ),
                                ),
                                if (_titleError) ...[
                                  const SizedBox(height: 4),
                                  buildText(
                                    'Task title is required',
                                    kRed,
                                    textTiny,
                                    FontWeight.w500,
                                    TextAlign.start,
                                    TextOverflow.clip,
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Description field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildText(
                                  'Description (Optional)',
                                  kBlackColor,
                                  textSmall,
                                  FontWeight.w600,
                                  TextAlign.start,
                                  TextOverflow.clip,
                                ),
                                const SizedBox(height: 8),
                                BuildTextField(
                                  hint: "Task Description",
                                  controller: description,
                                  inputType: TextInputType.multiline,
                                  fillColor: kWhiteColor,
                                  onChange: (value) {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Update button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: kWhiteColor,
                            backgroundColor: _hasChanges ? kPrimaryColor : kGrey2,
                            padding: const EdgeInsets.all(16),
                            elevation: _hasChanges ? 2 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: state is TasksLoading || !_hasChanges
                              ? null
                              : () {
                            if (_validateForm()) {
                              var taskModel = TaskModel(
                                id: widget.taskModel.id,
                                title: title.text.trim(),
                                description: description.text.trim(),
                                completed: widget.taskModel.completed,
                                startDateTime: _rangeStart,
                                stopDateTime: _rangeEnd,
                              );
                              context.read<TasksBloc>().add(
                                  UpdateTaskEvent(taskModel: taskModel));
                            }
                          },
                          child: state is TasksLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  kWhiteColor),
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.update, size: 20),
                              const SizedBox(width: 8),
                              buildText(
                                _hasChanges ? 'Update Task' : 'No Changes',
                                kWhiteColor,
                                textMedium,
                                FontWeight.w600,
                                TextAlign.center,
                                TextOverflow.clip,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}