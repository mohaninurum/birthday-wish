import 'package:flutter/cupertino.dart';

import '../../constant/uris.dart';
import '../../core/networking/network_api_service.dart';
import '../../model/category_list_Model/category_list_model.dart';
import '../../model/frame_list_model/frame_list_model.dart';
import '../../model/get_sticker_list/get_sticker_list_model.dart';
import '../../model/templates_model/templates_model.dart';

class EditProvider extends ChangeNotifier {
  NetworkApiService apiService = NetworkApiService();
  StickerResponse? stickerResponse;
  TemplateResponse? templatesModel;
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
  getTemplatesList() async {
    isLoading=true;
    notifyListeners();
    templatesModel = TemplateResponse.fromJson({
      "frameType": "double",
      "items": [
        {
          "scale": 1.0,
          "rotation": 0.0,
          "position": { "dx": 100.0, "dy": 200.0 },
          "fontFamily": "Poppins",
          "value": "Happy Anniversary!",
          "fontSize": 20.0,
          "fontWeight": "FontWeight.w500",
          "color": 4280391411,
          "fontStyle": "FontStyle.normal",
          "type": "text"
        }
      ],
      "background1": {
        "type": "image",
        "position": { "dx": 0.0, "dy": 0.0 },
        "rotation": 0.0,
        "scale": 1.0,
        "value": "assets/backgrounds/bg1.png"
      },
    }
    );
    isLoading=true;
    notifyListeners();
    // final response = await apiService.getGetApiResponse(Urls.getStickerList, {});
    //
    // response.fold(
    //       (error) => print("Error: ${error.message}"),
    //       (data) {
    //     if(data["status"]==true){
    //       print("StickerResponse: $data");
    //       stickerResponse = StickerResponse.fromJson(data);
    //       isLoading = false;
    //       notifyListeners();
    //     }else{
    //     }
    //   },
    // );
  }

}