import 'package:flutter/cupertino.dart';

import '../../constant/uris.dart';
import '../../core/networking/network_api_service.dart';
import '../../model/WishesSubCategoryListModel/all_wishes_category_list_model.dart';
import '../../model/birthday_catogory_model/wishes_category_mdoel.dart';
import '../../model/category_list_Model/category_list_model.dart';
import '../../model/frame_list_model/frame_list_model.dart';
import '../../model/wishesSub_Category_ListByID/wishesSub_category_listByID.dart';
import '../../model/wishes_details_list_model/wishes_details_list_model.dart';

class HomeProvider extends ChangeNotifier {
  NetworkApiService apiService = NetworkApiService();
   FrameResponse? frameResponse;
   FrameResponse? categoryFrameResponse;
  CategoryResponse? categoryResponseModel;
  WishesCategoryResponse? wishesCategoryResponse;
  WishesSubCategoryListModel? wishesSubCategoryListModel;
  WishessubCategoryListbyidModel? wishessubCategoryListbyidModel;
  WishesDetailsListModel? wishesDetailsListModel;
   bool isLoading = true;
   bool isLoadingframe = true;
   String categoryTitle='Frame';
   String wisheSubCategoryID='1';
   String wishesCategoryID='1';
   String statusCode='200';



  getFrameList() async {
    isLoading=true;
    notifyListeners();
    final response = await apiService.getGetApiResponse(Urls.frameList, {});

    response.fold(
          (error) => print("Error: ${error.message}"),
          (data) {
            if(data["status"]==true){
              print("Response: $data");
              frameResponse = FrameResponse.fromJson(data);
              isLoading = false;
              notifyListeners();
            }else{
              isLoading = false;
              notifyListeners();
            }
          },
    );
    }
  getFrameListByCategoryId(id,title) async {
    statusCode='200';
    isLoadingframe=true;
    categoryTitle=title;
    notifyListeners();
    final response = await apiService.getGetApiResponse("${Urls.getFrameListByCategoryId}$id", {});

    response.fold(
          (error) => print("Error: ${error.message}"),
          (data) {
            if(data["status"]==true){
              print("Response: $data");
              categoryFrameResponse = FrameResponse.fromJson(data);
              isLoadingframe = false;
              notifyListeners();
            }else{
              isLoading = false;
              notifyListeners();
            }
          },
    );

    }


  getCategoryList() async {    statusCode='200';
    isLoading=true;
    notifyListeners();
    final response = await apiService.getGetApiResponse(Urls.getCategoryList, {});
    response.fold(
          (error) => print("Error: ${error.message}"),
          (data) {
            if(data["status"]==true){
              print("Category: $data");
              categoryResponseModel = CategoryResponse.fromJson(data);
              isLoading = false;
              notifyListeners();
            }else{
              isLoading = false;
              notifyListeners();
            }
          },
    );

    }
  wishesCategoryList() async {    statusCode='200';
    isLoading=true;
    notifyListeners();
    final response = await apiService.getGetApiResponse(Urls.wishesCategoryList, {});
    response.fold(
          (error) => print("Error: ${error.message}"),
          (data) {
            if(data["status"]==true){
              print("Category: $data");
              wishesCategoryResponse = WishesCategoryResponse.fromJson(data);
              isLoading = false;
              notifyListeners();
            }else{
              isLoading = false;
              notifyListeners();
            }
          },
    );

    }

  wishesSubCategoryList() async {    statusCode='200';
    isLoading=true;
    notifyListeners();
    final response = await apiService.getGetApiResponse(Urls.wishesSubCategoryList, {});
    response.fold(
          (error) => print("Error: ${error.message}"),
          (data) {
            if(data["status"]==true){
              print("Category: $data");
              wishesCategoryResponse = WishesCategoryResponse.fromJson(data);
              isLoading = false;
              notifyListeners();
            }else{
              isLoading = false;
              notifyListeners();
            }
          },
    );
    }

  setWishesCategoryList(String id) async {
    isLoading=true;
    wishesCategoryID=id;
  }


  getWishesSubCategoryList() async {    statusCode='200';
    isLoading=true;
    notifyListeners();
    final response = await apiService.getGetApiResponse("${Urls.wishesSubCategoryListByID}$wishesCategoryID", {});
    print("Response: $response");

    response.fold(
          (error) => print("Error: ${error.message}"),
          (data) {
            print(data);
            if(data["status"]==true){
              print("Category: $data");
              wishesSubCategoryListModel = WishesSubCategoryListModel.fromJson(data);
              isLoading = false;
              notifyListeners();
            }else{
              if(data["status"]==false){
                statusCode="404";
                print(">>>>>statusCode>>>>>${statusCode}");
              }
              isLoading = false;
              notifyListeners();
            }
          },
    );
    }

  setWishesSubCategoryListByID(String id) async {
    isLoading=true;
    wisheSubCategoryID=id;
    }

  wishesDetailsSubCategoryListByID() async {    statusCode='200';
    isLoading=true;
    notifyListeners();
    final response = await apiService.getGetApiResponse("${Urls.wishesWishesDetailsListByID}$wisheSubCategoryID", {});
    response.fold(
          (error) => print("Error: ${error.message}"),
          (data) {
            if(data["status"]==true){
              print("Category: $data");
              wishesDetailsListModel = WishesDetailsListModel.fromJson(data);
              isLoading = false;
              notifyListeners();
            }else{
              isLoading = false;
              notifyListeners();
            }
          },
    );
    }




  void selectFrame(String frameId) {
    notifyListeners();
  }
}