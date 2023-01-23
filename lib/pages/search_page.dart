import 'package:flutter/material.dart';
import 'package:hostel_booking_application/providers/hostels_provider.dart';
import 'package:provider/provider.dart';

import '../providers/the_hostel.dart';
import '../utilities/themes.dart';
import '../widgets/hostel_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  static String routeName = '/searchPage';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  @override
  bool get wantKeepAlive => true;
  String hostelName = '';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                autofocus: false,
                onChanged: (value) {},
                onFieldSubmitted: (value) {
                  setState(() {
                    hostelName = value;
                  });
                },
              ),
              Expanded(
                child: hostelName.isEmpty
                    ? const Center(
                        child: Text('Search for hostels'),
                      )
                    : FutureBuilder(
                        future:
                            Provider.of<HostelsProvider>(context, listen: false)
                                .fetchHostelsByNameSearch(hostelName),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  color: ThemeClass.primaryColor,
                                  strokeWidth: 2.0,
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Check your Internet Connection'),
                                  const Text('And'),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {});
                                    },
                                    child: const Text('Try Again'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Consumer<HostelsProvider>(
                              builder: (ctx, hostelsData, child) {
                                if (hostelsData
                                    .hostelsByNameSearch.isNotEmpty) {
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: hostelsData
                                          .hostelsByNameSearch.length,
                                      itemBuilder: (context, i) {
                                        return ChangeNotifierProvider<
                                            TheHostel>.value(
                                          value: hostelsData
                                              .hostelsByNameSearch[i],
                                          child: const HostelWidget(),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return Center(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [Text('No hostels found.')],
                                  ));
                                }
                              },
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
