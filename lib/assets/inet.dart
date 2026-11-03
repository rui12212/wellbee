// <pro>
const String baseUri = 'https://api.wellbee-studio.com/api/v6/';

// <ngrok> ローカルDocker（ngrok経由で実機から接続。URLは起動ごとに変わる）
// HTTPSなのでATS例外は不要
// final String baseUri =
//     'https://fdbc-240b-c020-640-cbcf-8d5c-334f-ff9e-8957.ngrok-free.app/api/v6/';

// <dev>
// final String baseUri = 'http://10.0.2.2:80/';  // Android emulator
// final String baseUri = 'http://192.168.150.159:8000/';  // iOS real device (Mac Wi-Fi IP, Django direct)

// <iproxy> To connect local Docker on Mac to Iphone via cable
// final String baseUri = "http://localhost:80/";

// <ngrok> To connect iPhone to Mac's local server via tethering
// final String baseUri = "https://b298-240b-c010-453-e4f9-a49b-a7be-8209-f4e3.ngrok-free.app/";
