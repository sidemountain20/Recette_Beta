import SwiftUI

// プレビュー用のContentView（Firebase依存関係なし）
struct PreviewContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // レシピタブ
            VStack {
                Text("レシピ")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("レシピ一覧がここに表示されます")
                    .foregroundColor(.secondary)
            }
            .tabItem {
                Image(systemName: "carrot")
                Text("レシピ")
            }
            .tag(0)
            
            // 買い物リストタブ
            VStack {
                Text("買い物リスト")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("買い物リストがここに表示されます")
                    .foregroundColor(.secondary)
            }
            .tabItem {
                Image(systemName: "square.and.pencil")
                Text("買い物リスト")
            }
            .tag(1)
            
            // カロリータブ
            VStack {
                Text("カロリー")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("カロリー管理がここに表示されます")
                    .foregroundColor(.secondary)
            }
            .tabItem {
                Image(systemName: "scalemass")
                Text("カロリー")
            }
            .tag(2)
            
            // ホームタブ
            VStack {
                Text("ホーム")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("ホーム画面がここに表示されます")
                    .foregroundColor(.secondary)
            }
            .tabItem {
                Image(systemName: "house")
                Text("ホーム")
            }
            .tag(3)
        }
        .accentColor(Color(red: 0.9, green: 0.2, blue: 0.2))
    }
}

#Preview {
    PreviewContentView()
}
