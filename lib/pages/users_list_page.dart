import 'package:flutter/material.dart';
import 'package:hostel_booking_application/providers/the_user_provider.dart';
import 'package:hostel_booking_application/providers/users_provider.dart';
import 'package:provider/provider.dart';

import '../utilities/themes.dart';
import '../widgets/user_item.dart';

class UsersListPage extends StatefulWidget {
  static String routeName = '/usersListPage';
  const UsersListPage({Key? key}) : super(key: key);

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  @override
  void initState() {
    Provider.of<UsersProvider>(context, listen: false).fetchAllUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ThemeClass.primaryColor,
          title: const Text('Users'),
        ),
        body: FutureBuilder(
          future: Provider.of<UsersProvider>(context, listen: false)
              .fetchAllUsers(),
          builder: (ctx, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  children: [
                    Text(
                      snapshot.error.toString(),
                    ),
                    const Text(
                      'and',
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: const Text('Try again...'),
                    ),
                  ],
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(
                    color: ThemeClass.primaryColor,
                    strokeWidth: 2,
                  ),
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Consumer<UsersProvider>(
                builder: (ctx, usersData, child) {
                  if (usersData.users.isNotEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {},
                      child: ListView.builder(
                        itemCount: usersData.users.length,
                        itemBuilder: (ctx, i) {
                          return ChangeNotifierProvider<TheUser>.value(
                            value: usersData.users[i],
                            child: const UserItem(),
                          );
                        },
                      ),
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [Text('No users found.')],
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text('Something went wrong.'),
              );
            }
          },
        ),
      ),
    );
  }
}
