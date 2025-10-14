import 'package:flutter/cupertino.dart';

import '../../constant/uris.dart';
import '../../core/networking/network_api_service.dart';
import '../../model/category_list_Model/category_list_model.dart';
import '../../model/frame_list_model/frame_list_model.dart';

class HomeProvider extends ChangeNotifier {
  NetworkApiService apiService = NetworkApiService();
   FrameResponse? frameResponse;
  CategoryResponse? categoryResponseModel;
   bool isLoading = true;

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
            }
          },
    );
    }


  getCategoryList() async {
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
            }
          },
    );

    }




  void selectFrame(String frameId) {
    notifyListeners();
  }
}