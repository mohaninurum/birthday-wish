import 'package:flutter/cupertino.dart';

import '../../constant/uris.dart';
import '../../core/networking/network_api_service.dart';
import '../../model/category_list_Model/category_list_model.dart';
import '../../model/frame_list_model/frame_list_model.dart';
import '../../model/get_sticker_list/get_sticker_list_model.dart';

class EditProvider extends ChangeNotifier {
  NetworkApiService apiService = NetworkApiService();
  StickerResponse? stickerResponse;
  bool isLoading = true;

  getStickerList() async {
    isLoading=true;
    notifyListeners();
    final response = await apiService.getGetApiResponse(Urls.getStickerList, {});

    response.fold(
          (error) => print("Error: ${error.message}"),
          (data) {
        if(data["status"]==true){
          print("StickerResponse: $data");
          stickerResponse = StickerResponse.fromJson(data);
          isLoading = false;
          notifyListeners();
        }else{
        }
      },
    );

  }

}