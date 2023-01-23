import 'package:flutter/material.dart';
import 'package:hostel_booking_application/pages/home_page.dart';
import 'package:hostel_booking_application/pages/profile_page.dart';
import 'package:hostel_booking_application/pages/search_page.dart';

class DashboardPage extends StatefulWidget {
  static String routeName = '/dashboardPage';
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _pageController = PageController(
    initialPage: 0,
  );

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: const [
              HomePage(),
              SearchPage(),
              ProfilePage(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedFontSize: 18,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              backgroundColor: Colors.white,
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              backgroundColor: Colors.white,
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              backgroundColor: Colors.white,
              label: '',
            ),
          ],
          type: BottomNavigationBarType.shifting,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.black,
          iconSize: 25,
          onTap: _onItemTapped,
          elevation: 10,
        ),
      ),
    );
  }
}
