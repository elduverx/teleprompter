import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    
    // Configuración persistente
    @AppStorage("teleprompterText") private var teleprompterText: String = "Escribe tu guion aquí..."
    @AppStorage("scrollSpeed") private var scrollSpeed: Double = 2.0
    @AppStorage("fontSize") private var fontSize: Double = 32.0
    
    // Estado local
    @State private var isEditingText = false
    @State private var isShowingSettings = false
    @State private var scrollOffset: CGFloat = 0
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            // Camera Feed
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
            
            // Teleprompter Overlay (Invisible to recording)
            VStack {
                // Movido a la parte superior para mejor contacto visual con la cámara
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        Text(teleprompterText)
                            .font(.system(size: CGFloat(fontSize), weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            // Sombras para crear un efecto de contorno y mejorar legibilidad
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: -1, y: -1)
                            .padding()
                            .frame(width: geometry.size.width)
                            .offset(y: scrollOffset)
                    }
                    .frame(height: 250) // Un poco más pequeño para no tapar tanto
                    .background(Color.black.opacity(0.15)) // Más transparente
                    .cornerRadius(15)
                }
                .frame(height: 250)
                .padding(.horizontal)
                .padding(.top, 60) // Espacio para la muesca/Dynamic Island
                
                Spacer()
                
                // Controls
                HStack(spacing: 30) {
                    if !cameraManager.isRecording {
                        Button(action: {
                            isEditingText.toggle()
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                        }
                    }
                    
                    Button(action: {
                        cameraManager.toggleRecording()
                        if cameraManager.isRecording {
                            startScrolling()
                        } else {
                            stopScrolling()
                        }
                    }) {
                        Circle()
                            .fill(cameraManager.isRecording ? Color.red : Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .shadow(radius: 5)
                    }
                    
                    if !cameraManager.isRecording {
                        Button(action: {
                            isShowingSettings.toggle()
                        }) {
                            Image(systemName: "gearshape.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                        }
                    }
                    
                    if cameraManager.isRecording {
                        Button(action: {
                            scrollOffset = 0
                        }) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                        }
                    }
                }
                .padding(.bottom, 30)
                .animation(.easeInOut, value: cameraManager.isRecording)
            }
        }
        .sheet(isPresented: $isEditingText) {
            VStack {
                Text("Editar Guion")
                    .font(.headline)
                    .padding()
                
                TextEditor(text: $teleprompterText)
                    .padding()
                    .border(Color.gray, width: 1)
                
                Button(action: {
                    isEditingText.toggle()
                    scrollOffset = 0
                }) {
                    Text("Guardar")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
        }
        .sheet(isPresented: $isShowingSettings) {
            VStack(spacing: 20) {
                Text("Configuración del Teleprompter")
                    .font(.headline)
                    .padding(.top)
                
                VStack(alignment: .leading) {
                    Text("Velocidad: \(String(format: "%.1f", scrollSpeed))")
                    Slider(value: $scrollSpeed, in: 0.5...10.0, step: 0.5)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("Tamaño de texto: \(Int(fontSize))")
                    Slider(value: $fontSize, in: 16...72, step: 2)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    isShowingSettings.toggle()
                }) {
                    Text("Cerrar")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
        }
    }
    
    func startScrolling() {
        scrollOffset = 150 // Empezar un poco más arriba desde el fondo
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation(.linear(duration: 0.05)) {
                scrollOffset -= scrollSpeed
            }
        }
    }
    
    func stopScrolling() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    ContentView()
}
