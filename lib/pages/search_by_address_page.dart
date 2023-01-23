import 'package:flutter/material.dart';
import 'package:hostel_booking_application/providers/hostels_provider.dart';
import 'package:provider/provider.dart';

import '../providers/the_hostel.dart';
import '../utilities/themes.dart';
import '../widgets/hostel_widget.dart';

class SearchPageByAddress extends StatefulWidget {
  const SearchPageByAddress({Key? key}) : super(key: key);

  static String routeName = '/searchPageByAddress';

  @override
  State<SearchPageByAddress> createState() => _SearchPageByAddressState();
}

class _SearchPageByAddressState extends State<SearchPageByAddress>
    with AutomaticKeepAliveClientMixin<SearchPageByAddress> {
  @override
  bool get wantKeepAlive => true;
  String hostelAddress = '';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                autofocus: true,
                onChanged: (value) {},
                onFieldSubmitted: (value) {
                  setState(() {
                    hostelAddress = value;
                  });
                },
              ),
              Expanded(
                child: hostelAddress.isEmpty
                    ? const Center(
                        child: Text('Enter the address'),
                      )
                    : FutureBuilder(
                        future:
                            Provider.of<HostelsProvider>(context, listen: false)
                                .fetchHostelsByAddressSearch(hostelAddress),
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
                                    .hostelsByAddressSearch.isNotEmpty) {
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: hostelsData
                                          .hostelsByAddressSearch.length,
                                      itemBuilder: (context, i) {
                                        return ChangeNotifierProvider<
                                            TheHostel>.value(
                                          value: hostelsData
                                              .hostelsByAddressSearch[i],
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
