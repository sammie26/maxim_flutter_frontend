import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Used for currency formatting (requires dependency)

// Assuming your AppColors are in this path
import '../../../theme/app_theme.dart';
// Assuming you have a standard clean AppBar for detail pages


// --- Goal Data Model ---

enum GoalStatus { inProgress, completed, paused }

class FinancialGoal {
  final String id;
  final String name;
  double targetAmount;
  double currentSavings;
  final DateTime startDate;
  DateTime? targetDate;
  final IconData icon;
  GoalStatus status;

  FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentSavings,
    required this.startDate,
    this.targetDate,
    required this.icon,
    this.status = GoalStatus.inProgress,
  });

  double get progressPercentage => currentSavings / targetAmount;
  bool get isCompleted => currentSavings >= targetAmount;
}

// --- Mock Data ---

List<FinancialGoal> mockGoals = [
  FinancialGoal(
    id: '1',
    name: 'New Laptop',
    targetAmount: 25000,
    currentSavings: 18500,
    startDate: DateTime(2025, 1, 1),
    targetDate: DateTime(2025, 12, 31),
    icon: Icons.laptop_mac_rounded,
    status: GoalStatus.inProgress,
  ),
  FinancialGoal(
    id: '2',
    name: 'Vacation to Sharm',
    targetAmount: 12000,
    currentSavings: 12000,
    startDate: DateTime(2025, 3, 1),
    targetDate: DateTime(2025, 8, 1),
    icon: Icons.beach_access_rounded,
    status: GoalStatus.completed,
  ),
  FinancialGoal(
    id: '3',
    name: 'Emergency Fund',
    targetAmount: 5000,
    currentSavings: 3000,
    startDate: DateTime(2025, 10, 1),
    targetDate: DateTime(2026, 3, 31),
    icon: Icons.local_hospital_rounded,
    status: GoalStatus.inProgress,
  ),
];

// --- Stateful Goal Screen ---

class FinancialGoalsScreen extends StatefulWidget {
  const FinancialGoalsScreen({super.key});

  @override
  State<FinancialGoalsScreen> createState() => _FinancialGoalsScreenState();
}

class _FinancialGoalsScreenState extends State<FinancialGoalsScreen> {
  // Use a copy of mock data to manage state changes (adding new goals)
  List<FinancialGoal> _goals = List.from(mockGoals);
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US', // Use appropriate locale for grouping
    symbol: 'EGP',
    decimalDigits: 0,
  );

  // --- HANDLER FOR ADDING A NEW GOAL ---

  void _addNewGoal(FinancialGoal newGoal) {
    setState(() {
      _goals.add(newGoal);
    });
  }

  // --- NAVIGATION: OPEN NEW GOAL FORM ---

  void _openCreateGoalForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateGoalScreen(onGoalCreated: _addNewGoal),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // BUILD METHODS
  // ----------------------------------------------------------------------

  // NOTE: This uses the simple detail AppBar from the Refer a Friend screen.
  PreferredSizeWidget _buildSleekAppBar() {
    return AppBar(
      backgroundColor: AppColors.kLightBackground,
      elevation: 0,
      title: const Text(
        "Financial Goals",
        style: TextStyle(
          color: AppColors.kDarkBackground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: AppColors.kDarkBackground,
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline_rounded),
          color: AppColors.kProgressColor,
          onPressed: () => _openCreateGoalForm(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort goals to show inProgress first
    _goals.sort((a, b) => a.status.index.compareTo(b.status.index));

    return Scaffold(
      backgroundColor: AppColors.kLightBackground,
      appBar: _buildSleekAppBar(),
      body: _goals.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                return _buildGoalCard(_goals[index]);
              },
            ),
      // Optional: Floating Action Button to create a goal if the AppBar action isn't clear enough
      floatingActionButton: _goals.isEmpty ? FloatingActionButton.extended(
        onPressed: () => _openCreateGoalForm(context),
        label: const Text('New Goal'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.kProgressColor,
        foregroundColor: AppColors.kAccentWhite,
      ) : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.savings_rounded,
              size: 80,
              color: AppColors.kDullTextColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Goals Set Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.kDarkBackground,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Start your journey by setting your first financial goal. What are you saving for?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.kDullTextColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(FinancialGoal goal) {
    final double progress = goal.progressPercentage.clamp(0.0, 1.0);
    final bool isCompleted = goal.isCompleted;

    String formatCurrency(double amount) {
      return currencyFormatter.format(amount);
    }

    // Determine card colors based on status
    Color cardColor = isCompleted
        ? AppColors.kProgressColor.withValues(alpha: 0.1)
        : AppColors.kAccentWhite;
    Color progressColor = isCompleted
        ? AppColors.kProgressColor
        : AppColors.kProgressColor;
    Color iconColor = isCompleted
        ? AppColors.kProgressColor
        : AppColors.kDarkBackground;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted
            ? Border.all(color: AppColors.kProgressColor, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.kDullTextColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(goal.icon, color: iconColor, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  goal.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kDarkBackground,
                  ),
                ),
              ),
              // Status Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.kProgressColor
                      : AppColors.kHostAccentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Saving',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? AppColors.kAccentWhite
                        : AppColors.kHostAccentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.kDullTextColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 8),

          // Amounts and Target
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved: ${formatCurrency(goal.currentSavings)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kDarkBackground,
                ),
              ),
              Text(
                'Target: ${formatCurrency(goal.targetAmount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.kDullTextColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% complete',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.kHostAccentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (goal.targetDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Target Date: ${DateFormat('MMM dd, yyyy').format(goal.targetDate!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.kDullTextColor.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// CREATE NEW GOAL SCREEN
// ----------------------------------------------------------------------

class CreateGoalScreen extends StatefulWidget {
  final Function(FinancialGoal) onGoalCreated;

  const CreateGoalScreen({super.key, required this.onGoalCreated});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  String _goalName = '';
  double _targetAmount = 0.0;
  double _initialDeposit = 0.0;
  DateTime? _targetDate;
  IconData _selectedIcon = Icons.star_border_rounded;

  final TextEditingController _dateController = TextEditingController();

  // Mock icon list for selection
  final List<IconData> mockIcons = [
    Icons.car_rental_rounded,
    Icons.house_rounded,
    Icons.flight_takeoff_rounded,
    Icons.school_rounded,
    Icons.laptop_mac_rounded,
    Icons.diamond_rounded,
    Icons.savings_rounded,
  ];

  // Helper to pick a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.kProgressColor,
            colorScheme: ColorScheme.light(
              primary: AppColors.kProgressColor, // Header background
              onPrimary: AppColors.kAccentWhite, // Header text
              onSurface: AppColors.kDarkBackground, // Body text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.kDarkBackground, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
        _dateController.text = DateFormat('MMM dd, yyyy').format(picked);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newGoal = FinancialGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _goalName,
        targetAmount: _targetAmount,
        currentSavings: _initialDeposit,
        startDate: DateTime.now(),
        targetDate: _targetDate,
        icon: _selectedIcon,
      );

      widget.onGoalCreated(newGoal);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newGoal.name} goal created!'),
          backgroundColor: AppColors.kProgressColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kLightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kLightBackground,
        elevation: 0,
        title: const Text(
          "Set New Goal",
          style: TextStyle(
            color: AppColors.kDarkBackground,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.kDarkBackground,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Goal Name (Object) ---
              _buildTextFormField(
                label: 'What are you saving for?',
                hint: 'e.g., Car down payment, Wedding, New Phone',
                icon: Icons.label_important_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for your goal.';
                  }
                  return null;
                },
                onSaved: (value) => _goalName = value!,
              ),
              const SizedBox(height: 20),

              // --- Target Amount (Price) ---
              _buildTextFormField(
                label: 'Target Amount (EGP)',
                hint: 'e.g., 50000',
                icon: Icons.monetization_on_outlined,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid amount.';
                  }
                  if (double.parse(value) <= 100) {
                    return 'Target must be greater than EGP 100.';
                  }
                  return null;
                },
                onSaved: (value) => _targetAmount = double.parse(value!),
              ),
              const SizedBox(height: 20),

              // --- Initial Deposit ---
              _buildTextFormField(
                label: 'Initial Deposit (Optional)',
                hint: 'e.g., 500',
                icon: Icons.account_balance_wallet_outlined,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  // Allows empty, but checks validity if entered
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    return 'Please enter a valid amount.';
                  }
                  return null;
                },
                onSaved: (value) =>
                    _initialDeposit = double.tryParse(value ?? '0') ?? 0,
              ),
              const SizedBox(height: 20),

              // --- Target Date ---
              _buildDateFormField(),
              const SizedBox(height: 20),

              // --- Goal Icon Selector ---
              _buildIconSelector(),
              const SizedBox(height: 40),

              // --- Create Goal Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kProgressColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon:
                      const Icon(Icons.check, color: AppColors.kAccentWhite),
                  label: const Text(
                    'Create Financial Goal',
                    style: TextStyle(
                      color: AppColors.kAccentWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------- WIDGET BUILDERS -------------------

  Widget _buildTextFormField({
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.kDarkBackground,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.kDarkBackground),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.kProgressColor),
            hintText: hint,
            hintStyle:
                TextStyle(color: AppColors.kDullTextColor.withValues(alpha: 0.6)),
            filled: true,
            fillColor: AppColors.kAccentWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.kProgressColor, width: 2),
            ),
          ),
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildDateFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Completion Date (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.kDarkBackground,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          style: const TextStyle(color: AppColors.kDarkBackground),
          decoration: InputDecoration(
            prefixIcon:
                const Icon(Icons.calendar_month, color: AppColors.kProgressColor),
            hintText: 'Select a date',
            hintStyle:
                TextStyle(color: AppColors.kDullTextColor.withValues(alpha: 0.6)),
            filled: true,
            fillColor: AppColors.kAccentWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.kProgressColor, width: 2),
            ),
          ),
          onTap: () => _selectDate(context),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Goal Icon',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.kDarkBackground,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mockIcons.length,
            itemBuilder: (context, index) {
              final icon = mockIcons[index];
              final isSelected = _selectedIcon == icon;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.kProgressColor.withValues(alpha: 0.8)
                        : AppColors.kAccentWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.kProgressColor
                          : AppColors.kDullTextColor.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: isSelected
                        ? AppColors.kAccentWhite
                        : AppColors.kDarkBackground,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}