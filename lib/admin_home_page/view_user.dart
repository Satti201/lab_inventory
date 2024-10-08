import 'package:flutter/material.dart';
import 'package:lab_inventory/Api_Services/api_services.dart';
import 'package:lab_inventory/Models/role_model.dart';
import 'package:lab_inventory/Models/user_model.dart';
import 'package:lab_inventory/admin_home_page/add_new_user.dart';
import 'package:lab_inventory/admin_home_page/view_users_details.dart';
import 'package:lab_inventory/logout_menu.dart';
import 'package:lab_inventory/widget/custom_app_bar.dart';

class ViewUser1 extends StatelessWidget {
  final List<RolesModel> _roleList;
  final UserModel userModel;

  const ViewUser1(this.userModel, this._roleList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.lightGreen[800],
      appBar: CustomAppBar(
        //backgroundColor: Colors.green[900],
        title: const Text('Admin Home'),
        actions: [
          PopupMenuButton<int>(
            offset: Offset(-10, 40),
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.deepPurple,
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    Text(
                      "Logout",
                      style: TextStyle(fontSize: 14),
                    )
                  ],
                ),
              ),
            ],
            onSelected: (item) => LogMenu.selectedItem(context, item),
          ),
        ],
      ),
      body: _ViewUserBody(_roleList),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add New User',
        elevation: 20,
        child: const Icon(
          Icons.add,
          color: Colors.deepPurple,
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddNewUser(_roleList)));
        },
      ),
    );
  }
}

class _ViewUserBody extends StatefulWidget {
  final List<RolesModel> _roleList;

  const _ViewUserBody(this._roleList, {Key? key}) : super(key: key);

  @override
  _ViewUserBodyState createState() => _ViewUserBodyState();
}

class _ViewUserBodyState extends State<_ViewUserBody> {
  ApiServices api = ApiServices();
  List<RolesModel> items = [];
  RolesModel? value;

  List<UserModel> _userList = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _refreshUsersList();
      items = widget._roleList.toList();
    });
  }

  Future _refreshUsersList() async {
    List<UserModel> useList = await api.fetchUser();
    _userList = [];

    setState(() {
      for (var i = 0; i < useList.length; i++) {
        _userList.add(useList[i]);
      }
    });
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        label: Text('Name'),
        numeric: false,
        tooltip: 'Name and UserName',
      ),
      const DataColumn(
        label: Text('Email'),
        numeric: false,
        tooltip: 'Email',
      ),
      const DataColumn(
        label: Text('Role'),
        numeric: false,
        tooltip: 'Role of User',
      ),
    ];
  }

  DataRow _createRow(UserModel userModel) {
    return DataRow(
      key: ValueKey(userModel.userId),
      onSelectChanged: (selected) {
        String rName = getRoleType(userModel.roleId);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewUserDetails(userModel, rName)));
      },
      cells: [
        DataCell(
          Text(userModel.userName),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Text(userModel.userEmail),
          ),
        ),
        DataCell(
          Text(_getRoleAbbrivation(userModel.roleId.toString())),
        ),
      ],
    );
  }

  String getRoleType(int asId) {
    for (int i = 0; i < items.length; i++) {
      if (asId == items[i].roleId) {
        return items[i].roleType;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    /*
        setState(() {
          _refreshUsersList();
          value = null;
        });
      */
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text(
                    'Account & Permissions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              const SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _refreshUsersList();
                    value = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text(
                  'Refresh',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            height: 10,
          ),
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dividerThickness: 5,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1)),
                      dataRowMinHeight: 40,
                      dataTextStyle: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      headingRowColor: WidgetStateColor.resolveWith(
                          (states) => Colors.transparent),
                      headingRowHeight: 40,
                      headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 16),
                      horizontalMargin: 10,
                      showBottomBorder: true,
                      showCheckboxColumn: false,
                      columns: _createColumns(),
                      rows: _userList.map((e) => _createRow(e)).toList(),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //get Trim Name
  String getTrimName(String str) {
    String newStr = '';
    for (int i = 0; i < str.length; i++) {
      if (str[i].toUpperCase() == str[i]) {
        newStr = newStr + str[i];
      }
    }
    newStr = newStr.trim();
    newStr = newStr.replaceAll(' ', '');
    return (newStr);
  }

  //get course title
  String _getRoleAbbrivation(String roleId) {
    String rType = '';
    for (int i = 0; i < widget._roleList.length; i++) {
      if (widget._roleList[i].roleId.toString() == roleId) {
        rType = widget._roleList[i].roleType;
      }
    }
    String newRType = getTrimName(rType);
    return newRType;
  }
}
