import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/services/user_service.dart';
import 'package:syncio_capstone/utils/helpers.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController inputController = TextEditingController();
  late FocusNode focus = FocusNode();
  List<SingleAccountInfo> accounts = [];
  int page = 1;
  final int pageSize = 10;
  bool isFetching = false;
  bool isHaveMore = true;
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    focus.requestFocus();
    inputController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    inputController.removeListener(_onSearchChanged);
    inputController.dispose();
    focus.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        accounts.clear(); // Clear previous results on new search
        page = 1;
        isHaveMore = true;
      });
      _onGetUser();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isFetching &&
        isHaveMore) {
      _onGetUser();
    }
  }

  Future<void> _onGetUser() async {
    if (isFetching || !isHaveMore || inputController.text.trim().isEmpty) {
      return;
    }

    final int? userID = await Helpers().getUserId();
    if (userID == null) return;

    setState(() {
      isFetching = true;
    });

    try {
      final SearchAccountRequest request = SearchAccountRequest(
        requestAccountId: userID,
        queryString: inputController.text,
        page: page,
        pageSize: pageSize,
      );
      final response = await UserService().searchAccount(request);

      if (response.accounts == null || response.accounts!.isEmpty) {
        setState(() {
          isHaveMore = false;
        });
      } else {
        setState(() {
          accounts.addAll(response.accounts!);
          page++;
          if (response.accounts!.length <= pageSize) {
            isHaveMore = false;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      setState(() {
        isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextFormField(
                focusNode: focus,
                controller: inputController,
                cursorColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                  hintText: "Search users...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 15,
                  );
                },
                controller: _scrollController,
                itemCount: accounts.length + (isFetching ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == accounts.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final user = accounts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed("profileScreen",
                          arguments: {
                            "userID": accounts[index].accountID.toString(),
                            "isSelf": false
                          });
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.avatarURL),
                        backgroundColor: Colors.white,
                        radius: 24,
                      ),
                      title: Text(
                        user.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
