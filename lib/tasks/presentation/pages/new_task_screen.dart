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

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
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

  @override
  void initState() {
    _selectedDay = _focusedDay;
    super.initState();
  }

  _onRangeSelected(DateTime? start, DateTime? end, DateTime focusDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusDay;
      _rangeStart = start;
      _rangeEnd = end;
      _dateError = false; // Clear error when dates are selected
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
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: kGrey3.withOpacity(0.05),
        appBar: const CustomAppBar(
          title: 'Create New Task',
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
                  if (state is AddTaskFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        getSnackBar(state.error, kRed));
                  }
                  if (state is AddTasksSuccess) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        getSnackBar('Task created successfully!', Colors.green));
                  }
                },
                builder: (context, state) {
                  return ListView(
                    children: [
                      // Calendar section with title
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
                                  'Select Date Range',
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
                            if (_dateError) ...[
                              const SizedBox(height: 4),
                              buildText(
                                'Please select a date range for your task',
                                kRed,
                                textTiny,
                                FontWeight.w500,
                                TextAlign.start,
                                TextOverflow.clip,
                              ),
                            ],
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
                              firstDay: DateTime.now().subtract(const Duration(days: 1)),
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
                                    : 'Tap on calendar to select date range',
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
                                Icon(Icons.task_alt, size: 20, color: kPrimaryColor),
                                const SizedBox(width: 8),
                                buildText(
                                  'Task Details',
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
                                    hint: "Enter task title",
                                    controller: title,
                                    inputType: TextInputType.text,
                                    fillColor: kWhiteColor,
                                    onChange: (value) {
                                      if (_titleError && value.trim().isNotEmpty) {
                                        setState(() {
                                          _titleError = false;
                                        });
                                      }
                                    },
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
                                  hint: "Add task description...",
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

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kGrey1,
                                side: BorderSide(color: kGrey2),
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: buildText(
                                'Cancel',
                                kGrey1,
                                textMedium,
                                FontWeight.w600,
                                TextAlign.center,
                                TextOverflow.clip,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: kWhiteColor,
                                backgroundColor: kPrimaryColor,
                                padding: const EdgeInsets.all(16),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: state is TasksLoading
                                  ? null
                                  : () {
                                if (_validateForm()) {
                                  final String taskId = DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString();
                                  var taskModel = TaskModel(
                                    id: taskId,
                                    title: title.text.trim(),
                                    description: description.text.trim(),
                                    startDateTime: _rangeStart,
                                    stopDateTime: _rangeEnd,
                                  );
                                  context.read<TasksBloc>().add(
                                      AddNewTaskEvent(taskModel: taskModel));
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
                                  const Icon(Icons.save, size: 20),
                                  const SizedBox(width: 8),
                                  buildText(
                                    'Create Task',
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
                        ],
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