import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hostel_booking_application/pages/search_by_address_page.dart';
import 'package:hostel_booking_application/providers/hostels_provider.dart';
import 'package:hostel_booking_application/providers/the_hostel.dart';
import 'package:hostel_booking_application/utilities/themes.dart';
import 'package:provider/provider.dart';
import '../repositories/google_maps_repository.dart';
import '../widgets/hostel_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true;
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // -- determines your location

    GoogleMapsRepository.determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(
            8,
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    SearchPageByAddress.routeName,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  margin: const EdgeInsets.only(
                    left: 5,
                    right: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      7,
                    ),
                    color: ThemeClass.primaryColor.withOpacity(
                      0.4,
                    ),
                  ),
                  height: 42,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Search by address . . .'),
                      Icon(
                        Icons.search,
                      ),
                    ],
                  ),
                ).animate().slideX(),
              ),
              const SizedBox(
                height: 5,
              ),
              Expanded(
                child: FutureBuilder(
                  future: Provider.of<HostelsProvider>(context, listen: false)
                      .fetchAllHostels(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                            Text(snapshot.error.toString()),
                            const Text('And'),
                            TextButton(
                              onPressed: () async {
                                setState(() {});
                              },
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Consumer<HostelsProvider>(
                        builder: (context, hostelData, child) {
                          return RefreshIndicator(
                            key: _refreshIndicatorKey,
                            onRefresh: () async {
                              await hostelData.fetchAllHostels();
                            },
                            child: hostelData.hostels.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'images/bed.png',
                                          height: 130,
                                          width: 130,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Text('No hostels available.'),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: hostelData.hostels.length,
                                    itemBuilder: (context, i) {
                                      return ChangeNotifierProvider<
                                          TheHostel>.value(
                                        value: hostelData.hostels[i],
                                        child: const HostelWidget(),
                                      );
                                    },
                                  ),
                          );
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
