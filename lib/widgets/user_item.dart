import 'package:flutter/material.dart';
import 'package:hostel_booking_application/providers/the_user_provider.dart';
import 'package:provider/provider.dart';

import '../pages/user_details_page.dart';

class UserItem extends StatelessWidget {
  const UserItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider<TheUser>.value(
                value: user,
                child: const UserDetailsPage(),
              ),
            ),);
      },
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 8,
        ),
        child: Card(
          elevation: 2,
          child: ListTile(
            title: Text(user.userName),
            subtitle: Text('Role: ${user.role}'),
            trailing: TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChangeNotifierProvider<TheUser>.value(
                        value: user,
                        child: const UserDetailsPage(),
                      ),
                    ));
              },
              child: const Text(
                'View Details',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
