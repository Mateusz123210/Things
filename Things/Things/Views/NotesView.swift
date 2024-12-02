import SwiftUI

struct NotesView: View{
    
    @EnvironmentObject var router: Router
    @ObservedObject var loginStatus: LoginStatus
    @Environment(\.colorScheme) var colorScheme
    @State private var screenHeight = UIScreen.main.bounds.height
    @State private var screenWidth = UIScreen.main.bounds.width
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showAlert2 = false
    @State private var alertMessage2 = ""
    @State private var showAlert3 = false
    @State private var alertMessage3 = ""
    @State private var notesFound: Bool = false
    @State private var userNotes: [NoteSchema] = []
    @State private var fetched: Bool = false
    @State private var interfaceState: Modes = Modes.browse
    @State private var addSchema: NoteAddSchema = NoteAddSchema(name: "", text: "")

    let notesService = NotesService()
    
    func showAlert(message: String){
        alertMessage = message
        showAlert = true
    }
    
    func notesFetched(notes: [NoteSchema]){

        userNotes = notes
        notesFound = true
        
        if (fetched == false) {
            fetched = true
        }
    }
    
    func handleFetchError(message: String){
        showAlert(message: message)
    }
    
    func handleLogout() {
        loginStatus.handleLogout()
        router.navigateToRoot()
    }
    func handleCredentialsError(){
        alertMessage3 = "Internal error occured. You will be logged out!"
        showAlert3 = true
    }
    
    func handleNoNotes(){
        if (fetched == false) {
            fetched = true
        }
        notesFound = false
        userNotes = []
    }
    
    func fetchNotes(){
        DispatchQueue.global().async{
            notesService.getAllNotes(loginStatus: loginStatus, viewRef: self)
        }
    }
       
    func addNote(){
        interfaceState = Modes.add
    }
    
    func confirmAdd() {

        if addSchema.name.count == 0 {
            alertMessage = "Write note topic!"
            showAlert = true
            return
        }
        
        if addSchema.text.count == 0 {
            alertMessage = "Write note text!"
            showAlert = true
            return
        }

        DispatchQueue.global().async{
            notesService.addNote(paramsData: addSchema, loginStatus: loginStatus, viewRef: self)
            
        }
        
    }
    
    func backToBrowse() {
        addSchema = NoteAddSchema(name: "", text: "")
        interfaceState = Modes.browse
    }
    
    var body: some View{
        Group {
            if(orientation == UIDeviceOrientation.landscapeLeft || orientation == UIDeviceOrientation.landscapeRight){
                VStack{
                    VStack{
                        HStack{
                            Text("Things")
                                .fontWeight(.bold)
                                .font(Font.system(size: 40))
                                .foregroundStyle(.darkBlue341943)
                                .padding(.bottom, 5)
                                .padding(.leading, 16)
                            Spacer()
                            
                            HStack{
                                Button(action: {
                                    router.navPath.removeLast()
                                    router.navigate(destination: .categories)
                                }){
                                    Image(systemName: "house")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.darkBlue341943)
                                }
                                .padding()
                                
                                Button(action: {
                                    router.navPath.removeLast()
                                    router.navigate(destination: .account)
                                }){
                                    Image(systemName: "person.crop.circle")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.darkBlue341943)
                                }
                                .padding(.trailing, 16)
                            }
                            .frame(alignment: .bottomTrailing)
                        }
                        .background(colorScheme == .dark ? .black : .blue5AC8FA)
                        .padding(.bottom, 16)
                        
                        HStack {
                            Text("Notes")
                                .fontWeight(.medium)
                                .font(Font.system(size: 32))
                                .foregroundStyle(colorScheme == .dark ? .white:
                                        .black)
                            Spacer()
                            if interfaceState == Modes.browse {
                                
                                Button("Refresh"){
                                    fetchNotes()
                                }
                                .fontWeight(.semibold)
                                .font(Font.system(size: 17))
                                .foregroundStyle(.lightGray3C3C43)
                                
                                Button("Add"){
                                    addNote()
                                }
                                .fontWeight(.semibold)
                                .font(Font.system(size: 17))
                                .foregroundStyle(.lightGray3C3C43)
                            }
                        }
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                        .padding(.top, 2)
                        
                    }
                    .frame(alignment: .topLeading)
                    
                    Spacer()
                    if interfaceState == Modes.browse {
                        if(fetched == true){
                            if(notesFound == true) {
                                ScrollView{
                                    
                                    VStack {
                                        ForEach(userNotes.indices, id: \.self) {index in
                                            
                                            Button(
                                                action: {
                                                    router.navigate(destination: .note(noteName: userNotes[index].name))
                                                }
                                            ){
                                                Note(name: userNotes[index].name, text: userNotes[index].text)
                                            }
                                        }
                                    }
                                }
                            }
                            else{
                                VStack{
                                    Text("You don't have any notes yet!")
                                        .fontWeight(.medium)
                                        .font(Font.system(size: 28))
                                        .foregroundStyle(colorScheme == .dark ? .white:
                                                .black)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                    
                                }
                                .frame(alignment: .center)
                                Spacer()
                            }
                        }
                    } else {
                        ScrollView{
                            VStack {
                                HStack {
                                    Button("Cancel"){
                                        backToBrowse()
                                    }
                                    .fontWeight(.bold)
                                    .font(Font.system(size: 24))
                                    .foregroundStyle(.lightBlue00A7FF)
                                    
                                    Spacer()
                                    
                                    Button("Save"){
                                        confirmAdd()
                                    }
                                    .fontWeight(.bold)
                                    .font(Font.system(size: 24))
                                    .foregroundStyle(.lightGray3C3C43)
                                    
                                    
                                }
                                .padding(16)
                                
                                TextField("Enter note topic...", text: $addSchema.name)
                                    .padding(24)
                                    .background(colorScheme == .dark ? .black : .white)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .fontWeight(.bold)
                                    .font(Font.system(size: 36))
                                    .border(Color.white, width: 1)
                                    .frame(width: 0.7 * screenWidth)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.gray, lineWidth: 1)
                                            
                                    )
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                                
                                Text("Text")
                                    .fontWeight(.light)
                                    .font(Font.system(size: 24))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                TextEditor(text: $addSchema.text)
                                    .background(colorScheme == .dark ? .black : .white)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .font(Font.system(size: 20))
                                    .fontWeight(.semibold)
                                    .border(Color.gray, width: 1)
                                    .padding([.leading, .trailing], 16)
                                    .padding(.bottom, 16)
                                    .frame(height: 0.7 * screenHeight)
                                
                            }
                            .background(.lightBlueD6F1FF)
                            .cornerRadius(15)
                            .padding(16)
                            
                            
                            
                            
                        }
                        
                        
                        
                    }
    
                    
                }
            }else{
                VStack{
                    VStack{
                        VStack{
                            Text("Things")
                                .fontWeight(.bold)
                                .font(Font.system(size: 40))
                                .foregroundStyle(.darkBlue341943)
                                .padding(.bottom, 5)
                        }
                        .frame(width: screenWidth)
                        .background(colorScheme == .dark ? .black : .blue5AC8FA)
                        
                        HStack {
                            Text("Notes")
                                .fontWeight(.medium)
                                .font(Font.system(size: 32))
                                .foregroundStyle(colorScheme == .dark ? .white:
                                        .black)
                            Spacer()
                            if interfaceState == Modes.browse {
                                
                                Button("Refresh"){
                                    fetchNotes()
                                }
                                .fontWeight(.semibold)
                                .font(Font.system(size: 17))
                                .foregroundStyle(.lightGray3C3C43)
                                
                                Button("Add"){
                                    addNote()
                                }
                                .fontWeight(.semibold)
                                .font(Font.system(size: 17))
                                .foregroundStyle(.lightGray3C3C43)
                            }
                        }
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                        .padding(.top, 2)
                        
                        
                        
                    }
                    .frame(alignment: .topLeading)
                    
                    Spacer()
                    
                    if interfaceState == Modes.browse {
                        if(fetched == true){
                            if(notesFound == true) {
                                ScrollView{
                                    
                                    VStack {
                                        ForEach(userNotes.indices, id: \.self) {index in
                                            
                                            Button(
                                                action: {
                                                    router.navigate(destination: .note(noteName: userNotes[index].name))
                                                }
                                            ){
                                                Note(name: userNotes[index].name, text: userNotes[index].text)
                                            }
                                        }
                                    }
                                }
                            }
                            else{
                                VStack{
                                    Text("You don't have any notes yet!")
                                        .fontWeight(.medium)
                                        .font(Font.system(size: 28))
                                        .foregroundStyle(colorScheme == .dark ? .white:
                                                .black)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                    
                                }
                                .frame(alignment: .center)
                                Spacer()
                            }
                        }
                    } else {
                        ScrollView{
                            VStack {
                                HStack {
                                    Button("Cancel"){
                                        backToBrowse()
                                    }
                                    .fontWeight(.bold)
                                    .font(Font.system(size: 24))
                                    .foregroundStyle(.lightBlue00A7FF)
                                    
                                    Spacer()
                                    
                                    Button("Save"){
                                        confirmAdd()
                                    }
                                    .fontWeight(.bold)
                                    .font(Font.system(size: 24))
                                    .foregroundStyle(.lightGray3C3C43)
                                    
                                    
                                }
                                .padding(16)
                                
                                TextField("Enter note topic...", text: $addSchema.name)
                                    .padding(12)
                                    .background(colorScheme == .dark ? .black : .white)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .fontWeight(.bold)
                                    .font(Font.system(size: 24))
                                    .border(Color.white, width: 1)
                                    .frame(width: 0.7 * screenWidth)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.gray, lineWidth: 1)
                                            
                                    )
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                                
                                Text("Text")
                                    .fontWeight(.light)
                                    .font(Font.system(size: 24))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                TextEditor(text: $addSchema.text)
                                    .background(colorScheme == .dark ? .black : .white)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .font(Font.system(size: 20))
                                    .fontWeight(.semibold)
                                    .border(Color.gray, width: 1)
                                    .padding([.leading, .trailing], 16)
                                    .padding(.bottom, 16)
                                    .frame(height: 0.7 * screenHeight)
                                
                            }
                            .background(.lightBlueD6F1FF)
                            .cornerRadius(15)
                            .padding(16)
                            
                            
                            
                            
                        }
                        
                        
                        
                    }
                    
                    
                    
                    
                    VStack{
                        HStack{
                            Button(action: {
                                router.navigate(destination: .categories)
                            }){
                                Image(systemName: "house")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.darkBlue341943)
                            }
                            .padding()
                            .frame(width: screenWidth / 3)

                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 32))
                                .foregroundStyle(.iconF1F1F1)
                                .padding()
                                .frame(width: screenWidth / 3)
                            
                            Button(action: {
                                router.navigate(destination: .account)
                            }){
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.darkBlue341943)
                            }
                            .padding()
                            .frame(width: screenWidth / 3)
                           
                        }
                        .frame(width: screenWidth)
                        .background(colorScheme == .dark ? .black : .blue5AC8FA)
                        
                    }
                    .frame(alignment: .bottomTrailing)

                }
            }
            
            
        }
        .onAppear {
            fetchNotes()
        }
        .navigationBarBackButtonHidden(true)
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            
            if (UIDevice.current.orientation != UIDeviceOrientation.portraitUpsideDown){
                orientation = UIDevice.current.orientation
            }
            
        }
        .onChange(of: horizontalSizeClass) {
            updateScreenSize()
        }
        .onChange(of: verticalSizeClass) {
            updateScreenSize()
        }
        .alert(isPresented: $showAlert){
            Alert(title: Text("Error"), message: Text(alertMessage))
        }
        
    }
    
    private func updateScreenSize() {
        screenHeight = UIScreen.main.bounds.height
        screenWidth = UIScreen.main.bounds.width
    }
    
}
