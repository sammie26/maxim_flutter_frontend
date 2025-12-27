// import 'package:flutter/material.dart';

// const Color kDarkBackground = Color(0xFF222222);
// const Color kDeepestDark = Color(0xFF111111);
// const Color kLightBackground = Color(0xFFF0F0F0);
// const Color kAccentWhite = Colors.white;
// const Color kAccentGrey = Colors.white70;
// const Color kDullTextColor = Colors.black54;

// class AppBarExpanded extends StatelessWidget {
//   final String title;

//   const AppBarExpanded(this.title, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: kDarkBackground,
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
//       ),
//       child: SafeArea(
//         bottom: false, // Keep bottom padding manual for the menu
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min, // shrink to fit content
//             children: [
//               // Top Nav Icons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.notifications_none, color: kAccentWhite, size: 28),
//                     style: IconButton.styleFrom(padding: EdgeInsets.zero),
//                     onPressed: () => _navigateToBlankPage(context, 'Notifications'),
//                   ),
//                   const Text(
//                     'MAXIM',
//                     style: TextStyle(
//                       color: kAccentWhite,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                     ),
//                   ),
//                   IconButton(
//                     style: IconButton.styleFrom(padding: EdgeInsets.zero),
//                     icon: const Icon(Icons.person, color: kAccentWhite, size: 28),
//                     onPressed: () => _navigateToBlankPage(context, 'Profile'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               // Mini Navigation Menu
//               _buildMiniMenu(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMiniMenu(BuildContext context) {
//     const Map<String, String> menuItems = {
//       'Summary': "/summary",
//       'Cards': "/cards",
//       'Transactions': "/transactions",
//       'Rewards': "/rewards",
//     };

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: menuItems.entries.map((entry) {
//         final label = entry.key;
//         final path = entry.value;
//         final isSelected = label == title;

//         return TextButton(
//           onPressed: () {
//             // Optimization: Don't push if we are already on that page
//             if (!isSelected) {
//                // Use pushReplacement to avoid building a huge stack of pages
//                // if the user clicks back and forth between tabs
//                Navigator.of(context).pushReplacementNamed(path);
//             }
//           },
//           style: TextButton.styleFrom(
//             shape: StadiumBorder(
//               side: BorderSide(
//                 color: isSelected ? Colors.white : Colors.transparent,
//                 width: 1.5,
//               ),
//             ),
//             minimumSize: Size.zero,
//             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//             backgroundColor: isSelected ? Colors.white10 : Colors.transparent, // Added subtle highlight
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           ),
//           child: Text(
//             label,
//             style: TextStyle(
//               color: isSelected ? Colors.white : Colors.white70, // Dim non-selected items
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
//             )
//           ),
//         );
//       }).toList(),
//     );
//   }

//   void _navigateToBlankPage(BuildContext context, String title) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => Scaffold(
//           appBar: AppBar(
//             title: Text(title, style: const TextStyle(color: kDarkBackground)),
//             backgroundColor: kLightBackground,
//             iconTheme: const IconThemeData(color: kDarkBackground),
//             elevation: 0,
//           ),
//           body: Center(child: Text('You navigated to $title.')),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

const Color kDarkBackground = Color(0xFF222222);
const Color kDeepestDark = Color(0xFF111111);
const Color kLightBackground = Color(0xFFF0F0F0);
const Color kAccentWhite = Colors.white;
const Color kAccentGrey = Colors.white70;
const Color kDullTextColor = Colors.black54;

class AppBarExpanded extends StatelessWidget {
  final String title;

  const AppBarExpanded(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kDarkBackground,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false, // Keep bottom padding manual for the menu
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // shrink to fit content
            children: [
              // Top Nav Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: kAccentWhite,
                      size: 28,
                    ),
                    style: IconButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () =>
                        _navigateToBlankPage(context, 'Notifications'),
                  ),
                  const Text(
                    'MAXIM',
                    style: TextStyle(
                      color: kAccentWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(padding: EdgeInsets.zero),
                    icon: const Icon(
                      Icons.person,
                      color: kAccentWhite,
                      size: 28,
                    ),
                    onPressed: () => _navigateToBlankPage(context, 'Profile'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Mini Navigation Menu
              _buildMiniMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMenu(BuildContext context) {
    const Map<String, String> menuItems = {
      'Summary': "/summary",
      'Cards': "/cards",
      'Transactions': "/transactions",
      'Rewards': "/rewards",
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: menuItems.entries.map((entry) {
        final label = entry.key;
        final path = entry.value;
        final isSelected = label == title;

        return TextButton(
          onPressed: () {
            if (!isSelected) {
              Navigator.of(context).pushNamed(path);
            }
          },
          style: TextButton.styleFrom(
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 1.5,
              ),
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _navigateToBlankPage(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title, style: const TextStyle(color: kDarkBackground)),
            backgroundColor: kLightBackground,
            iconTheme: const IconThemeData(color: kDarkBackground),
            elevation: 0,
          ),
          body: Center(child: Text('You navigated to $title.')),
        ),
      ),
    );
  }
}
