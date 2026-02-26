import AppKit
import AVFoundation
import CoreML
import SwiftUI
import Vision

struct HomeView: View {
    @State private var showHUD = false

    var body: some View {
        ZStack {
            if showHUD {
                HUDPrototypeView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showHUD = false
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            } else {
                LandingContentView(
                    onStartTap: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showHUD = true
                        }
                    },
                    onLearnTap: {}
                )
                .transition(.opacity)
            }
        }
        .background(Color.signalWhite)
        .animation(.easeInOut(duration: 0.3), value: showHUD)
    }
}

private struct HUDPrototypeView: View {
    let onExit: () -> Void

    @StateObject private var store = HUDPrototypeStore()

    var body: some View {
        GeometryReader { proxy in
            let metrics = HUDLayoutMetrics(size: proxy.size)

            HStack(spacing: 0) {
                leftPanel(metrics: metrics)
                    .frame(width: metrics.sidebarWidth)
                    .frame(maxHeight: .infinity)
                    .background(HUDPalette.panelBackground)
                    .overlay(alignment: .trailing) {
                        Rectangle()
                            .fill(HUDPalette.sidebarDivider)
                            .frame(width: 1)
                    }

                stagePanel(metrics: metrics)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        }
        .onAppear {
            store.startRealtime()
        }
        .onDisappear {
            store.stopRealtime()
        }
    }

    private func leftPanel(metrics: HUDLayoutMetrics) -> some View {
        VStack(spacing: metrics.appleSectionSpacing) {
            headerPanel(metrics: metrics)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: metrics.appleSectionSpacing) {
                    panelCard(title: "Models", systemImage: "cpu.fill") {
                        modelsSection(metrics: metrics)
                    }

                    panelCard(title: "Event Log", systemImage: "list.bullet.rectangle.portrait") {
                        logSection(metrics: metrics)
                    }

                    if metrics.showHeatMap {
                        panelCard(title: "Heat Map", systemImage: "square.grid.3x3.fill") {
                            heatMapSection(metrics: metrics)
                        }
                    }

                    panelCard(title: "Controls", systemImage: "switch.2") {
                        controlsSection(metrics: metrics)
                    }
                }
                .padding(.bottom, metrics.sectionPadding)
            }
        }
        .padding(.horizontal, metrics.sectionPadding)
        .padding(.vertical, metrics.sectionPadding)
        .environment(\.colorScheme, .dark)
    }

    private func headerPanel(metrics: HUDLayoutMetrics) -> some View {
        HStack(alignment: .top) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Situation Monitor")
                        .font(.headline)
                    Text("Realtime vision telemetry")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "dot.scope.display")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.blue)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text(store.cameraStateText)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.thinMaterial, in: Capsule())

                Text(store.clockText)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08))
        )
    }

    private func controlsSection(metrics: HUDLayoutMetrics) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ControlGroup {
                Button(action: {}) {
                    Label("Camera", systemImage: "camera.viewfinder")
                }

                Button(action: { store.togglePause() }) {
                    Label(store.isPaused ? "Resume" : "Pause", systemImage: store.isPaused ? "play.fill" : "pause.fill")
                }

                Button(role: .destructive, action: onExit) {
                    Label("Exit", systemImage: "xmark")
                }
            }
            .controlSize(.small)

            VStack(alignment: .leading, spacing: 6) {
                LabeledContent("Confidence") {
                    Text(store.thresholdText)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                .font(.caption)

                Slider(value: $store.threshold, in: 0.1 ... 0.95)
                    .controlSize(.small)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Filters")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: metrics.filterChipMinimum, maximum: 130), spacing: 6)], alignment: .leading, spacing: 6) {
                    ForEach(Array(HUDPrototypeStore.allLabels.enumerated()), id: \.offset) { item in
                        filterChip(for: item.element)
                    }
                }
            }
        }
    }

    private func filterChip(for label: String) -> some View {
        let binding = Binding<Bool>(
            get: { store.enabledLabels.contains(label) },
            set: { enabled in
                if enabled != store.enabledLabels.contains(label) {
                    store.toggleLabel(label)
                }
            }
        )

        return Toggle(label.capitalized, isOn: binding)
            .font(.caption2.weight(.semibold))
            .toggleStyle(.button)
            .tint(HUDPalette.color(for: label))
    }

    private func heatMapSection(metrics: HUDLayoutMetrics) -> some View {
        HeatMapGridView(cells: store.heatMap, columns: HUDPrototypeStore.heatMapColumns, rows: HUDPrototypeStore.heatMapRows)
            .frame(height: metrics.heatMapHeight)
    }

    private func modelsSection(metrics: HUDLayoutMetrics) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            LabeledContent("Camera") {
                Text(store.cameraStateText)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.thinMaterial, in: Capsule())
            }
            LabeledContent("Detector") {
                Text(store.detectorStateText)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.thinMaterial, in: Capsule())
            }
            LabeledContent("Frame Rate") {
                Text(store.fpsText)
                    .font(.caption.monospacedDigit())
            }
            .foregroundStyle(.secondary)
        }
        .font(.caption)
    }

    private func logSection(metrics: HUDLayoutMetrics) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 6) {
                ForEach(Array(store.eventLog.prefix(metrics.maxLogEntries))) { entry in
                    HStack(spacing: 6) {
                        Text(entry.time)
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)

                        Image(systemName: entry.marker == "+" ? "plus.circle.fill" : "minus.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(entry.color)

                        Text(entry.label.capitalized)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
            }
        }
        .frame(maxHeight: metrics.logHeight)
    }

    private func panelCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        GroupBox {
            content()
        } label: {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
        }
    }

    private func stagePanel(metrics: HUDLayoutMetrics) -> some View {
        ZStack(alignment: .bottom) {
            RealtimeStageBackground(service: store.cameraService)
                .overlay(Color.black.opacity(0.08))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            DetectionOverlayView(detections: store.activeSceneDetections, compact: metrics.isCompactWidth || metrics.isCompactHeight)

            VStack(spacing: 0) {
                Spacer()

                captionStrip(metrics: metrics)
            }
        }
        .clipped()
    }

    private func captionStrip(metrics: HUDLayoutMetrics) -> some View {
        HStack {
            Text(store.caption)
                .font(.system(size: metrics.captionTextSize, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.white.opacity(0.9))
                .lineSpacing(metrics.captionLineSpacing)
                .lineLimit(metrics.isCompactHeight ? 3 : 2)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, metrics.captionInnerPadding)
        .padding(.vertical, metrics.captionVerticalPadding)
        .frame(maxWidth: min(metrics.stageWidth * 0.88, 920), alignment: .leading)
        .background(Color.black.opacity(0.72))
        .overlay(
            Rectangle()
                .stroke(HUDPalette.liveRed.opacity(0.72), lineWidth: 1)
        )
        .padding(.horizontal, metrics.captionOuterPadding)
        .padding(.bottom, metrics.captionBottomPadding)
    }

}

private struct DetectionOverlayView: View {
    let detections: [HUDDetection]
    let compact: Bool

    var body: some View {
        GeometryReader { proxy in
            ForEach(detections) { detection in
                let frame = CGRect(
                    x: detection.rect.origin.x * proxy.size.width,
                    y: detection.rect.origin.y * proxy.size.height,
                    width: detection.rect.width * proxy.size.width,
                    height: detection.rect.height * proxy.size.height
                )

                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .stroke(detection.color, lineWidth: compact ? 1.6 : 2)

                    Text("\(detection.label.uppercased())  \(Int(detection.confidence * 100))")
                        .font(.system(size: compact ? 9 : 11, weight: .heavy, design: .monospaced))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, compact ? 2 : 3)
                        .background(detection.color)
                        .offset(x: 0, y: compact ? -20 : -24)
                }
                .frame(width: max(frame.width, compact ? 28 : 36), height: max(frame.height, compact ? 28 : 36))
                .position(x: frame.midX, y: frame.midY)
            }
        }
    }
}

private struct HUDLayoutMetrics {
    let size: CGSize

    var isCompactWidth: Bool { size.width < 1180 }
    var isCompactHeight: Bool { size.height < 760 }

    var sidebarWidth: CGFloat {
        let ratio = isCompactWidth ? 0.25 : 0.2
        let minWidth: CGFloat = isCompactWidth ? 216 : 248
        let maxWidth: CGFloat = isCompactWidth ? 272 : 310
        return min(max(size.width * ratio, minWidth), maxWidth)
    }

    var stageWidth: CGFloat {
        max(360, size.width - sidebarWidth)
    }

    var sectionPadding: CGFloat { isCompactHeight ? 8 : 10 }
    var appleSectionSpacing: CGFloat { isCompactHeight ? 8 : 10 }
    var blockSpacing: CGFloat { isCompactHeight ? 6 : 8 }
    var sectionHeaderSize: CGFloat { isCompactWidth ? 16 : 19 }
    var objectCountSize: CGFloat { isCompactWidth ? 42 : 50 }
    var bodyTextSize: CGFloat { isCompactWidth ? 12 : 14 }
    var metaTextSize: CGFloat { isCompactWidth ? 10 : 11 }
    var logTextSize: CGFloat { isCompactWidth ? 10 : 11 }
    var microTextSize: CGFloat { isCompactWidth ? 9 : 10 }
    var clockSize: CGFloat { isCompactWidth ? 18 : 20 }
    var fpsSize: CGFloat { isCompactWidth ? 20 : 24 }
    var thresholdValueSize: CGFloat { isCompactWidth ? 16 : 19 }
    var thresholdValueWidth: CGFloat { isCompactWidth ? 44 : 50 }

    var objectLabelWidth: CGFloat { isCompactWidth ? 42 : 50 }
    var scoreWidth: CGFloat { isCompactWidth ? 20 : 22 }
    var barHeight: CGFloat { isCompactWidth ? 4 : 5 }

    var heatMapHeight: CGFloat { isCompactHeight ? 100 : 122 }
    var logHeight: CGFloat { isCompactHeight ? 92 : 132 }
    var maxLogEntries: Int { isCompactHeight ? 14 : 20 }
    var showHeatMap: Bool { size.height > 610 }

    var chipTextSize: CGFloat { isCompactWidth ? 9 : 10 }
    var filterChipMinimum: CGFloat { isCompactWidth ? 52 : 58 }

    var buttonSide: CGFloat { isCompactWidth ? 24 : 26 }
    var buttonIconSize: CGFloat { isCompactWidth ? 11 : 12 }

    var liveBadgeTextSize: CGFloat { isCompactWidth ? 12 : 13 }
    var liveBadgeInset: CGFloat { isCompactWidth ? 10 : 14 }

    var captionTextSize: CGFloat {
        min(max(stageWidth * 0.031, 18), 34)
    }

    var captionLineSpacing: CGFloat { isCompactHeight ? 2 : 3 }
    var captionInnerPadding: CGFloat { isCompactWidth ? 14 : 18 }
    var captionVerticalPadding: CGFloat { isCompactHeight ? 10 : 14 }
    var captionOuterPadding: CGFloat { isCompactWidth ? 16 : 30 }
    var captionBottomPadding: CGFloat { isCompactHeight ? 8 : 12 }
}

private struct PrototypeStageArtwork: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.93, blue: 0.88),
                        Color(red: 0.92, green: 0.89, blue: 0.85),
                        Color(red: 0.8, green: 0.78, blue: 0.74)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.58))
                    .frame(width: proxy.size.width * 0.2, height: proxy.size.height * 0.28)
                    .position(x: proxy.size.width * 0.48, y: proxy.size.height * 0.56)

                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.07, green: 0.16, blue: 0.34))
                    .frame(width: proxy.size.width * 0.23, height: proxy.size.height * 0.4)
                    .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.67)

                Circle()
                    .fill(Color(red: 0.31, green: 0.23, blue: 0.18))
                    .frame(width: proxy.size.width * 0.12)
                    .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.36)

                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.95, green: 0.93, blue: 0.91))
                    .frame(width: proxy.size.width * 0.15, height: proxy.size.height * 0.22)
                    .position(x: proxy.size.width * 0.26, y: proxy.size.height * 0.66)

                Capsule()
                    .fill(Color(red: 0.88, green: 0.88, blue: 0.41))
                    .frame(width: proxy.size.width * 0.24, height: proxy.size.height * 0.08)
                    .rotationEffect(.degrees(-19))
                    .position(x: proxy.size.width * 0.62, y: proxy.size.height * 0.58)

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.22))
                    .frame(width: proxy.size.width * 0.18, height: proxy.size.height * 0.04)
                    .position(x: proxy.size.width * 0.84, y: proxy.size.height * 0.29)

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: proxy.size.width * 0.18, height: proxy.size.height * 0.04)
                    .position(x: proxy.size.width * 0.84, y: proxy.size.height * 0.49)

                RadialGradient(
                    colors: [Color.clear, Color.black.opacity(0.38)],
                    center: .center,
                    startRadius: 60,
                    endRadius: max(proxy.size.width, proxy.size.height) * 0.78
                )
            }
        }
    }
}

private struct HeatMapGridView: View {
    let cells: [Int]
    let columns: Int
    let rows: Int

    var body: some View {
        GeometryReader { proxy in
            let cellWidth = proxy.size.width / CGFloat(columns)
            let cellHeight = proxy.size.height / CGFloat(rows)

            ZStack(alignment: .topLeading) {
                ForEach(0 ..< rows, id: \.self) { row in
                    ForEach(0 ..< columns, id: \.self) { column in
                        let idx = row * columns + column
                        let value = idx < cells.count ? cells[idx] : 0

                        Rectangle()
                            .fill(color(for: value))
                            .frame(width: cellWidth - 1, height: cellHeight - 1)
                            .position(
                                x: CGFloat(column) * cellWidth + cellWidth / 2,
                                y: CGFloat(row) * cellHeight + cellHeight / 2
                            )
                    }
                }

                Path { path in
                    for col in 0 ... columns {
                        let x = CGFloat(col) * cellWidth
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: proxy.size.height))
                    }

                    for row in 0 ... rows {
                        let y = CGFloat(row) * cellHeight
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
            }
            .background(Color(red: 0.08, green: 0.085, blue: 0.095))
            .overlay(
                Rectangle()
                    .stroke(Color.white.opacity(0.24), lineWidth: 1)
            )
        }
    }

    private func color(for value: Int) -> Color {
        switch value {
        case 0: return Color.black.opacity(0.18)
        case 1 ... 3: return Color(red: 0.67, green: 0.98, blue: 0.18)
        case 4 ... 7: return Color(red: 0.96, green: 0.9, blue: 0.14)
        case 8 ... 11: return Color(red: 1, green: 0.53, blue: 0.16)
        default: return Color(red: 1, green: 0.24, blue: 0.2)
        }
    }
}

private struct RealtimeStageBackground: View {
    @ObservedObject var service: CameraService

    var body: some View {
        ZStack {
            if service.authorizationStatus == .authorized {
                CameraPreviewSurface(session: service.session)
            } else {
                PrototypeStageArtwork()
            }

            if service.authorizationStatus == .notDetermined {
                overlay(text: "Waiting for camera permission")
            } else if service.authorizationStatus == .restricted || service.authorizationStatus == .denied {
                overlay(text: "Camera access is blocked. Enable camera in macOS Settings.")
            } else if !service.isRunning {
                overlay(text: "Starting live camera feed")
            }
        }
    }

    @ViewBuilder
    private func overlay(text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .medium, design: .monospaced))
            .foregroundStyle(Color.white.opacity(0.88))
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.55))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
    }
}

private struct CameraPreviewSurface: NSViewRepresentable {
    let session: AVCaptureSession

    func makeNSView(context: Context) -> CameraPreviewContainerView {
        let view = CameraPreviewContainerView()
        view.previewLayer.session = session
        return view
    }

    func updateNSView(_ nsView: CameraPreviewContainerView, context: Context) {
        if nsView.previewLayer.session !== session {
            nsView.previewLayer.session = session
        }
    }
}

private final class CameraPreviewContainerView: NSView {
    let previewLayer = AVCaptureVideoPreviewLayer()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer = CALayer()
        previewLayer.videoGravity = .resizeAspectFill
        layer?.addSublayer(previewLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        previewLayer.frame = bounds
    }
}

private struct CameraFrameFeatures {
    let timestamp: Double
    let deltaTime: Double
    let fps: Double
    let brightness: Double
    let motion: Double
    let centroid: CGPoint
}

private final class CameraService: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published private(set) var authorizationStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @Published private(set) var isRunning = false

    let session = AVCaptureSession()

    var onFrameFeatures: ((CameraFrameFeatures) -> Void)?
    var onFrameSample: ((CMSampleBuffer, CameraFrameFeatures) -> Void)?
    var onStatusChange: ((String) -> Void)?

    private let sessionQueue = DispatchQueue(label: "signal.camera.session")
    private let sampleQueue = DispatchQueue(label: "signal.camera.sample")
    private var isConfigured = false
    private var lastTimestamp = CMTime.invalid
    private var smoothedFPS: Double = 0
    private var previousGrid: [UInt8] = []

    func start() {
        updateAuthorizationStatus()

        switch authorizationStatus {
        case .authorized:
            configureAndRun()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.updateAuthorizationStatus()
                    if granted {
                        self?.configureAndRun()
                    } else {
                        self?.emitStatus("DENIED")
                    }
                }
            }
        default:
            emitStatus("DENIED")
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
            DispatchQueue.main.async {
                self.isRunning = false
                self.emitStatus("PAUSE")
            }
        }
    }

    private func configureAndRun() {
        emitStatus("BOOT")

        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.configureSessionIfNeeded()
            guard self.isConfigured else {
                DispatchQueue.main.async {
                    self.emitStatus("ERROR")
                }
                return
            }

            if !self.session.isRunning {
                self.session.startRunning()
            }

            DispatchQueue.main.async {
                self.isRunning = true
                self.emitStatus("LIVE")
            }
        }
    }

    private func configureSessionIfNeeded() {
        guard !isConfigured else { return }

        session.beginConfiguration()
        session.sessionPreset = .high

        defer {
            session.commitConfiguration()
        }

        guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        guard session.canAddInput(input) else { return }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        output.setSampleBufferDelegate(self, queue: sampleQueue)
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)

        isConfigured = true
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let features = makeFeatures(from: sampleBuffer) else { return }
        onFrameSample?(sampleBuffer, features)
        DispatchQueue.main.async { [weak self] in
            self?.onFrameFeatures?(features)
        }
    }

    private func makeFeatures(from sampleBuffer: CMSampleBuffer) -> CameraFrameFeatures? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }

        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let deltaTime: Double
        if lastTimestamp.isValid {
            deltaTime = max(1.0 / 120.0, timestamp.seconds - lastTimestamp.seconds)
        } else {
            deltaTime = 1.0 / 24.0
        }
        lastTimestamp = timestamp

        let instantFPS = 1.0 / max(deltaTime, 0.0001)
        smoothedFPS = smoothedFPS == 0 ? instantFPS : (smoothedFPS * 0.84 + instantFPS * 0.16)

        let analyzed = analyze(pixelBuffer: pixelBuffer)

        return CameraFrameFeatures(
            timestamp: timestamp.seconds,
            deltaTime: deltaTime,
            fps: smoothedFPS,
            brightness: analyzed.brightness,
            motion: analyzed.motion,
            centroid: analyzed.centroid
        )
    }

    private func analyze(pixelBuffer: CVPixelBuffer) -> (brightness: Double, motion: Double, centroid: CGPoint) {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)

        guard width > 0,
              height > 0,
              let baseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
        else {
            return (0.5, 0.0, CGPoint(x: 0.5, y: 0.5))
        }

        let raw = baseAddress.assumingMemoryBound(to: UInt8.self)
        let gridX = 8
        let gridY = 6

        var sampleGrid: [UInt8] = []
        sampleGrid.reserveCapacity(gridX * gridY)

        var sum: Double = 0
        var weightedX: Double = 0
        var weightedY: Double = 0

        for gy in 0 ..< gridY {
            let y = gy * (height - 1) / max(gridY - 1, 1)
            let row = raw.advanced(by: y * bytesPerRow)
            for gx in 0 ..< gridX {
                let x = gx * (width - 1) / max(gridX - 1, 1)
                let value = row[x]
                sampleGrid.append(value)

                let intensity = Double(value)
                sum += intensity
                weightedX += intensity * Double(x)
                weightedY += intensity * Double(y)
            }
        }

        let brightness = sum / Double(sampleGrid.count * 255)
        let centroid: CGPoint
        if sum > 0 {
            centroid = CGPoint(
                x: min(max((weightedX / sum) / Double(width), 0), 1),
                y: min(max((weightedY / sum) / Double(height), 0), 1)
            )
        } else {
            centroid = CGPoint(x: 0.5, y: 0.5)
        }

        var motion: Double = 0
        if previousGrid.count == sampleGrid.count {
            var delta: Double = 0
            for i in sampleGrid.indices {
                delta += abs(Double(sampleGrid[i]) - Double(previousGrid[i]))
            }
            motion = delta / Double(sampleGrid.count * 255)
        }
        previousGrid = sampleGrid

        return (brightness, motion, centroid)
    }

    private func updateAuthorizationStatus() {
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }

    private func emitStatus(_ status: String) {
        onStatusChange?(status)
    }
}

private struct LocalizedDetection {
    let label: String
    let confidence: Double
    let rect: CGRect
}

private struct VisionDetectionSnapshot {
    let frameIndex: Int
    let timestamp: Double
    let fps: Double
    let motion: Double
    let centroid: CGPoint
    let objects: [LocalizedDetection]
    let inferenceDuration: Double
    let summary: String

    var labelConfidences: [String: Double] {
        var values: [String: Double] = [:]
        for object in objects {
            values[object.label] = max(values[object.label] ?? 0, object.confidence)
        }
        return values
    }
}

private final class VisionCoreMLDetectionService {
    private let processingQueue = DispatchQueue(label: "signal.vision.detector", qos: .userInitiated)
    private let stateQueue = DispatchQueue(label: "signal.vision.detector.state")
    private let baseFrameStride: Int
    private let targetLabels = ["person", "book", "pen", "cup", "banana"]
    private var frameCounter = 0
    private var isProcessing = false
    private var adaptiveFrameStride: Int
    private var targetInferenceFPS: Double
    private var smoothedInferenceDuration: Double = 0.12
    private var lastBookAssistTimestamp: CFAbsoluteTime = 0

    private let objectDetectionRequest: VNCoreMLRequest?
    private let detectorModeText: String

    private let synonyms: [String: [String]] = [
        "person": ["person", "human", "man", "woman"],
        "book": ["book", "notebook", "book jacket", "textbook", "magazine", "comic book", "binder", "newspaper", "menu", "file folder", "folder"],
        "pen": ["pen", "pencil", "marker", "highlighter", "stationery", "stationary"],
        "cup": ["cup", "mug", "coffee mug", "teacup", "bottle", "water bottle", "drink bottle", "thermos", "flask"],
        "banana": ["banana", "plantain", "fruit", "yellow banana"]
    ]

    var pipelineSummary: String {
        stateQueue.sync {
            "\(detectorModeText) s\(adaptiveFrameStride)"
        }
    }

    init(frameStride: Int, targetInferenceFPS: Double) {
        let stride = max(1, frameStride)
        self.baseFrameStride = stride
        self.adaptiveFrameStride = stride
        self.targetInferenceFPS = max(2, targetInferenceFPS)

        if let request = Self.makeCoreMLObjectRequest() {
            objectDetectionRequest = request
            detectorModeText = "coreml+vision"
        } else {
            objectDetectionRequest = nil
            detectorModeText = "vision-only"
        }
    }

    func setTargetInferenceFPS(_ value: Double) {
        let target = max(2, value)
        stateQueue.async { [weak self] in
            self?.targetInferenceFPS = target
        }
    }

    func process(
        sampleBuffer: CMSampleBuffer,
        frameFeatures: CameraFrameFeatures,
        completion: @escaping (VisionDetectionSnapshot) -> Void
    ) {
        frameCounter += 1
        let currentFrame = frameCounter
        let stride = currentStride()

        guard currentFrame % stride == 0 else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard beginProcessing() else { return }

        let features = frameFeatures
        processingQueue.async { [weak self] in
            guard let self else { return }
            defer { self.endProcessing() }

            let snapshot = self.runDetections(
                pixelBuffer: pixelBuffer,
                frameFeatures: features,
                frameIndex: currentFrame,
                strideUsed: stride
            )
            self.tuneStride(cameraFPS: features.fps, inferenceDuration: snapshot.inferenceDuration)

            DispatchQueue.main.async {
                completion(snapshot)
            }
        }
    }

    private func currentStride() -> Int {
        stateQueue.sync { adaptiveFrameStride }
    }

    private func beginProcessing() -> Bool {
        stateQueue.sync {
            guard !isProcessing else { return false }
            isProcessing = true
            return true
        }
    }

    private func endProcessing() {
        stateQueue.async { [weak self] in
            self?.isProcessing = false
        }
    }

    private func runDetections(
        pixelBuffer: CVPixelBuffer,
        frameFeatures: CameraFrameFeatures,
        frameIndex: Int,
        strideUsed: Int
    ) -> VisionDetectionSnapshot {
        let start = CFAbsoluteTimeGetCurrent()

        let coreMLObjects = runCoreMLLocalizedDetections(pixelBuffer: pixelBuffer)
        let visionObjects = runVisionFallbackDetections(pixelBuffer: pixelBuffer)
        let objects = mergeDetections(primary: coreMLObjects, secondary: visionObjects)
        let inferenceDuration = max(0, CFAbsoluteTimeGetCurrent() - start)
        let millis = Int((inferenceDuration * 1000).rounded())

        return VisionDetectionSnapshot(
            frameIndex: frameIndex,
            timestamp: frameFeatures.timestamp,
            fps: frameFeatures.fps,
            motion: frameFeatures.motion,
            centroid: frameFeatures.centroid,
            objects: objects,
            inferenceDuration: inferenceDuration,
            summary: "\(detectorModeText) #\(frameIndex) s\(strideUsed) \(millis)ms"
        )
    }

    private func runCoreMLLocalizedDetections(pixelBuffer: CVPixelBuffer) -> [LocalizedDetection] {
        guard let objectDetectionRequest else { return [] }

        do {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            try handler.perform([objectDetectionRequest])
        } catch {
            return []
        }

        guard let observations = objectDetectionRequest.results as? [VNRecognizedObjectObservation] else {
            return []
        }

        var detections: [LocalizedDetection] = []
        for observation in observations {
            let mapped = observation.labels
                .compactMap { candidate -> (label: String, confidence: Double)? in
                    guard let label = normalizedLabel(from: candidate.identifier) else { return nil }
                    return (label, Double(candidate.confidence))
                }
                .max(by: { $0.confidence < $1.confidence })
            guard let mapped else { continue }

            let label = mapped.label
            let confidence = calibratedConfidence(mapped.confidence, label: label, source: .coreML)
            guard confidence >= minimumConfidence(for: label) else { continue }

            detections.append(LocalizedDetection(
                label: label,
                confidence: confidence,
                rect: visionRectToHUD(observation.boundingBox)
            ))
        }

        return nmsFilteredDetections(detections, iouThreshold: 0.5, limit: 20)
    }

    private func mergeDetections(primary: [LocalizedDetection], secondary: [LocalizedDetection]) -> [LocalizedDetection] {
        nmsFilteredDetections(primary + secondary, iouThreshold: 0.5, limit: 20)
    }

    private func runVisionFallbackDetections(pixelBuffer: CVPixelBuffer) -> [LocalizedDetection] {
        var bestByLabel: [String: LocalizedDetection] = [:]

        do {
            let humanRequest = VNDetectHumanRectanglesRequest()
            let saliencyRequest = VNGenerateAttentionBasedSaliencyImageRequest()
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            try handler.perform([humanRequest, saliencyRequest])

            if let person = bestHumanDetection(from: humanRequest.results) {
                bestByLabel["person"] = person
            }

            let salientRegions = salientROIs(from: saliencyRequest.results)
            for roi in salientRegions {
                let classifications = classify(pixelBuffer: pixelBuffer, regionOfInterest: roi)
                guard let bestMatch = bestLabelMatch(in: classifications) else { continue }
                let calibrated = calibratedConfidence(bestMatch.confidence, label: bestMatch.label, source: .vision)
                guard calibrated >= minimumConfidence(for: bestMatch.label) else { continue }

                let detection = LocalizedDetection(
                    label: bestMatch.label,
                    confidence: calibrated,
                    rect: visionRectToHUD(roi)
                )

                if let current = bestByLabel[bestMatch.label], current.confidence >= detection.confidence {
                    continue
                }
                bestByLabel[bestMatch.label] = detection
            }

            if bestByLabel["book"] == nil {
                let now = CFAbsoluteTimeGetCurrent()
                if now - lastBookAssistTimestamp > 0.35,
                   let assistedBook = detectBookAssist(pixelBuffer: pixelBuffer, regions: salientRegions) {
                    bestByLabel["book"] = assistedBook
                    lastBookAssistTimestamp = now
                }
            }
        } catch {
            return targetLabels.compactMap { bestByLabel[$0] }
        }

        return targetLabels.compactMap { bestByLabel[$0] }
    }

    private func bestHumanDetection(from observations: [VNHumanObservation]?) -> LocalizedDetection? {
        guard let observations, !observations.isEmpty else { return nil }

        var best: VNHumanObservation?
        var bestScore: CGFloat = 0
        for observation in observations {
            let area = observation.boundingBox.width * observation.boundingBox.height
            let score = area * CGFloat(observation.confidence)
            if score > bestScore {
                bestScore = score
                best = observation
            }
        }

        guard let best else { return nil }
        return LocalizedDetection(
            label: "person",
            confidence: Double(best.confidence),
            rect: visionRectToHUD(best.boundingBox)
        )
    }

    private func salientROIs(from observations: [VNSaliencyImageObservation]?) -> [CGRect] {
        guard let observation = observations?.first else { return [] }
        guard let salient = observation.salientObjects else { return [] }

        var regions: [CGRect] = []
        regions.reserveCapacity(salient.count)
        for item in salient {
            let rect = normalizedVisionRect(item.boundingBox)
            let area = rect.width * rect.height
            if area > 0.02 {
                regions.append(rect)
            }
        }

        regions.sort { ($0.width * $0.height) > ($1.width * $1.height) }
        if regions.count > 5 {
            regions.removeSubrange(5...)
        }
        return regions
    }

    private func classify(pixelBuffer: CVPixelBuffer, regionOfInterest: CGRect) -> [VNClassificationObservation] {
        let request = VNClassifyImageRequest()
        request.regionOfInterest = normalizedVisionRect(regionOfInterest)

        do {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            try handler.perform([request])
            return Array((request.results ?? []).prefix(20))
        } catch {
            return []
        }
    }

    private func detectBookAssist(pixelBuffer: CVPixelBuffer, regions: [CGRect]) -> LocalizedDetection? {
        let candidates = regions
            .sorted { ($0.width * $0.height) > ($1.width * $1.height) }
            .prefix(3)
            .filter { ($0.width * $0.height) > 0.05 }

        var best: LocalizedDetection?
        for roi in candidates {
            let textCount = textObservationCount(pixelBuffer: pixelBuffer, regionOfInterest: roi)
            guard textCount >= 2 else { continue }

            let area = roi.width * roi.height
            let aspect = max(roi.width, roi.height) / max(min(roi.width, roi.height), 0.001)
            guard aspect < 3.4 else { continue }

            let confidence = min(0.48, 0.14 + (Double(textCount) * 0.07) + (Double(area) * 0.25))
            let detection = LocalizedDetection(label: "book", confidence: confidence, rect: visionRectToHUD(roi))
            if let current = best, current.confidence >= detection.confidence {
                continue
            }
            best = detection
        }
        return best
    }

    private func textObservationCount(pixelBuffer: CVPixelBuffer, regionOfInterest: CGRect) -> Int {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .fast
        request.usesLanguageCorrection = false
        request.minimumTextHeight = 0.02
        request.regionOfInterest = normalizedVisionRect(regionOfInterest)

        do {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            try handler.perform([request])
            let observations = request.results ?? []
            return observations.count
        } catch {
            return 0
        }
    }

    private func bestLabelMatch(in observations: [VNClassificationObservation]) -> (label: String, confidence: Double)? {
        var bestLabel: String?
        var bestConfidence = 0.0

        for observation in observations {
            guard let label = normalizedLabel(from: observation.identifier) else { continue }
            let confidence = Double(observation.confidence)
            if confidence > bestConfidence {
                bestConfidence = confidence
                bestLabel = label
            }
        }

        guard let bestLabel else { return nil }
        return (bestLabel, bestConfidence)
    }

    private func normalizedLabel(from identifier: String) -> String? {
        let value = identifier.lowercased()
        // Backward compatibility: existing checkpoint may still emit "phone" as class 4.
        if value == "phone" || value.contains("cell phone") || value.contains("mobile phone") {
            return "banana"
        }
        for (label, keys) in synonyms {
            for key in keys where value == key || value.contains(key) {
                return label
            }
        }
        return nil
    }

    private func minimumConfidence(for label: String) -> Double {
        switch label {
        case "person": return 0.10
        case "book": return 0.03
        case "pen", "banana": return 0.06
        case "cup": return 0.07
        default: return 0.06
        }
    }

    private enum DetectionSource {
        case coreML
        case vision
    }

    private func calibratedConfidence(_ raw: Double, label: String, source: DetectionSource) -> Double {
        let value: Double
        switch (label, source) {
        case ("book", .coreML):
            value = (raw * 1.9) + 0.05
        case ("book", .vision):
            value = (raw * 1.45) + 0.03
        case ("pen", _), ("banana", _):
            value = (raw * 1.25) + 0.02
        case ("cup", _):
            value = (raw * 1.15) + 0.02
        default:
            value = raw
        }
        return clamp(value, 0.0, 1.0)
    }

    private func nmsFilteredDetections(_ detections: [LocalizedDetection], iouThreshold: CGFloat, limit: Int) -> [LocalizedDetection] {
        let sorted = detections
            .filter { targetLabels.contains($0.label) }
            .sorted { $0.confidence > $1.confidence }

        var filtered: [LocalizedDetection] = []
        for detection in sorted {
            let overlaps = filtered.contains { existing in
                existing.label == detection.label && iou(existing.rect, detection.rect) > iouThreshold
            }
            if overlaps { continue }
            filtered.append(detection)
            if filtered.count >= limit { break }
        }
        return filtered
    }

    private func iou(_ lhs: CGRect, _ rhs: CGRect) -> CGFloat {
        let intersection = lhs.intersection(rhs)
        if intersection.isNull || intersection.isEmpty { return 0 }
        let intersectionArea = intersection.width * intersection.height
        let unionArea = (lhs.width * lhs.height) + (rhs.width * rhs.height) - intersectionArea
        guard unionArea > 0 else { return 0 }
        return intersectionArea / unionArea
    }

    private func visionRectToHUD(_ rect: CGRect) -> CGRect {
        let normalized = normalizedVisionRect(rect)
        return CGRect(
            x: normalized.minX,
            y: 1 - normalized.minY - normalized.height,
            width: normalized.width,
            height: normalized.height
        )
    }

    private func normalizedVisionRect(_ rect: CGRect) -> CGRect {
        let width = clamp(rect.width, 0.04, 0.96)
        let height = clamp(rect.height, 0.04, 0.96)
        let x = clamp(rect.origin.x, 0.0, 1.0 - width)
        let y = clamp(rect.origin.y, 0.0, 1.0 - height)
        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func tuneStride(cameraFPS: Double, inferenceDuration: Double) {
        stateQueue.async { [weak self] in
            guard let self else { return }

            self.smoothedInferenceDuration = (self.smoothedInferenceDuration * 0.82) + (inferenceDuration * 0.18)

            let safeCameraFPS = max(8, min(cameraFPS, 60))
            let desiredStride = Int(ceil(safeCameraFPS / self.targetInferenceFPS))

            let sustainableInferenceFPS = max(1.5, 0.8 / max(self.smoothedInferenceDuration, 0.001))
            let sustainableStride = Int(ceil(safeCameraFPS / sustainableInferenceFPS))

            let nextStride = max(self.baseFrameStride, max(desiredStride, sustainableStride))
            self.adaptiveFrameStride = self.clamp(nextStride, 1, 12)
        }
    }

    private static func makeCoreMLObjectRequest() -> VNCoreMLRequest? {
        let candidateNames = ["TinyObjectDetector", "SignalTinyDetector", "ChallengeTinyDetector"]
        for name in candidateNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "mlmodelc") else { continue }
            guard let model = try? MLModel(contentsOf: url) else { continue }
            guard let vnModel = try? VNCoreMLModel(for: model) else { continue }

            let request = VNCoreMLRequest(model: vnModel)
            request.imageCropAndScaleOption = .scaleFill
            return request
        }
        return nil
    }

    private func clamp<T: Comparable>(_ value: T, _ lower: T, _ upper: T) -> T {
        min(upper, max(lower, value))
    }
}

@MainActor
private final class HUDPrototypeStore: ObservableObject {
    static let allLabels = ["person", "book", "pen", "cup", "banana"]
    static let heatMapColumns = 14
    static let heatMapRows = 8

    @Published var threshold: Double = 0.2
    @Published var isPaused = false
    @Published var enabledLabels = Set(HUDPrototypeStore.allLabels)
    @Published private(set) var detections: [HUDDetection] = HUDPrototypeStore.seedDetections
    @Published private(set) var sceneDetections: [HUDDetection] = []
    @Published private(set) var heatMap = Array(repeating: 0, count: heatMapColumns * heatMapRows)
    @Published private(set) var eventLog: [HUDEvent] = []
    @Published private(set) var fps: Double = 0
    @Published private(set) var clockText = "--:--:--"
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var cameraStateText = "BOOT"
    @Published private(set) var detectorStateText = "LOCK"
    @Published private(set) var statusMessage = "vision infer #0"

    let cameraService = CameraService()
    private let detectorService = VisionCoreMLDetectionService(frameStride: 3, targetInferenceFPS: 10)
    private let narrationEngine = NarrationEngine()

    private var clockTimer: Timer?
    private var lastActiveLabels: Set<String> = []
    private var hasStartedRealtime = false
    private var lastInferenceFrameIndex = 0
    private var lastFrameStatusUpdateTimestamp = 0.0
    private var lastVisualUpdateTimestamp = 0.0
    private var pendingElapsedDelta: TimeInterval = 0
    private var smoothedVisualFPS = 0.0
    private let targetVisualFPS = 20.0
    private let targetInferenceFPS = 10.0
    private let clipDuration: TimeInterval = 28
    private let clockFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    private static let seedDetections: [HUDDetection] = [
        HUDDetection(label: "person", confidence: 0.0, rect: CGRect(x: 0.14, y: 0.15, width: 0.74, height: 0.82), color: HUDPalette.color(for: "person")),
        HUDDetection(label: "book", confidence: 0.0, rect: CGRect(x: 0.77, y: 0.22, width: 0.14, height: 0.08), color: HUDPalette.color(for: "book")),
        HUDDetection(label: "pen", confidence: 0.0, rect: CGRect(x: 0.57, y: 0.62, width: 0.12, height: 0.05), color: HUDPalette.color(for: "pen")),
        HUDDetection(label: "cup", confidence: 0.0, rect: CGRect(x: 0.16, y: 0.53, width: 0.16, height: 0.2), color: HUDPalette.color(for: "cup")),
        HUDDetection(label: "banana", confidence: 0.0, rect: CGRect(x: 0.68, y: 0.55, width: 0.12, height: 0.2), color: HUDPalette.color(for: "banana"))
    ]

    init() {
        clockText = clockFormatter.string(from: Date())
        detectorService.setTargetInferenceFPS(targetInferenceFPS)
        statusMessage = detectorService.pipelineSummary
        eventLog = [
            makeEvent(marker: "+", label: "hud", color: HUDPalette.readyGreen),
            makeEvent(marker: "+", label: "telemetry", color: HUDPalette.readyGreen)
        ]

        cameraService.onFrameFeatures = { [weak self] features in
            self?.handleFrame(features)
        }

        cameraService.onFrameSample = { [weak self] sampleBuffer, features in
            guard let self else { return }
            self.detectorService.process(sampleBuffer: sampleBuffer, frameFeatures: features) { [weak self] snapshot in
                self?.handleDetectionSnapshot(snapshot)
            }
        }

        cameraService.onStatusChange = { [weak self] status in
            guard let self else { return }
            self.cameraStateText = status
            if status == "DENIED" {
                self.statusMessage = "camera permission denied"
            }
        }

        startClockTimer()
    }

    deinit {
        clockTimer?.invalidate()
        cameraService.stop()
    }

    var activeDetections: [HUDDetection] {
        detections.filter { enabledLabels.contains($0.label) && $0.confidence >= effectiveThreshold(for: $0.label) }
    }

    var activeSceneDetections: [HUDDetection] {
        sceneDetections.filter { enabledLabels.contains($0.label) && $0.confidence >= effectiveThreshold(for: $0.label) }
    }

    var thresholdText: String {
        String(format: "%.2f", threshold)
    }

    var fpsText: String {
        String(format: "%.1f fps", fps)
    }

    var elapsedText: String {
        "\(timestamp(from: elapsed)) / \(timestamp(from: clipDuration))"
    }

    var caption: String {
        narrationEngine.caption(for: activeSceneDetections)
    }

    func startRealtime() {
        guard !hasStartedRealtime else { return }
        hasStartedRealtime = true
        cameraStateText = "BOOT"
        detectorService.setTargetInferenceFPS(targetInferenceFPS)
        statusMessage = detectorService.pipelineSummary
        lastVisualUpdateTimestamp = 0
        pendingElapsedDelta = 0
        smoothedVisualFPS = 0
        appendEvent(marker: "+", label: "camera", color: HUDPalette.readyGreen)
        cameraService.start()
    }

    func stopRealtime() {
        guard hasStartedRealtime else { return }
        hasStartedRealtime = false
        cameraService.stop()
        cameraStateText = "PAUSE"
        statusMessage = detectorService.pipelineSummary
        appendEvent(marker: "-", label: "camera", color: HUDPalette.hudOrange)
    }

    func togglePause() {
        isPaused.toggle()
        statusMessage = isPaused ? "detector paused" : "detector resumed"
        appendEvent(marker: isPaused ? "-" : "+", label: "detector", color: isPaused ? HUDPalette.hudOrange : HUDPalette.readyGreen)
    }

    func toggleLabel(_ label: String) {
        if enabledLabels.contains(label) {
            enabledLabels.remove(label)
        } else {
            enabledLabels.insert(label)
        }
    }

    func maxScore(for label: String) -> Int {
        let score = detections
            .filter { $0.label == label && enabledLabels.contains(label) }
            .map(\.confidence)
            .max() ?? 0

        return Int((score * 100).rounded())
    }

    private func startClockTimer() {
        clockTimer?.invalidate()
        clockTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.clockText = self.clockFormatter.string(from: Date())
            }
        }
    }

    private func handleFrame(_ frame: CameraFrameFeatures) {
        guard !isPaused else { return }

        pendingElapsedDelta += min(frame.deltaTime, 0.2)
        let updateInterval = 1.0 / targetVisualFPS
        guard frame.timestamp - lastVisualUpdateTimestamp >= updateInterval else { return }

        if lastVisualUpdateTimestamp > 0 {
            let visualInterval = max(0.001, frame.timestamp - lastVisualUpdateTimestamp)
            let instantVisualFPS = 1.0 / visualInterval
            smoothedVisualFPS = smoothedVisualFPS == 0 ? instantVisualFPS : (smoothedVisualFPS * 0.75 + instantVisualFPS * 0.25)
        }
        lastVisualUpdateTimestamp = frame.timestamp

        clockText = clockFormatter.string(from: Date())
        fps = max(0, min(smoothedVisualFPS == 0 ? frame.fps : smoothedVisualFPS, 24))

        elapsed += pendingElapsedDelta
        pendingElapsedDelta = 0
        if elapsed >= clipDuration { elapsed = 0 }

        decayHeatMap()

        if frame.timestamp - lastFrameStatusUpdateTimestamp > 0.5 {
            statusMessage = "\(detectorService.pipelineSummary) #\(lastInferenceFrameIndex)"
            lastFrameStatusUpdateTimestamp = frame.timestamp
        }
    }

    private func handleDetectionSnapshot(_ snapshot: VisionDetectionSnapshot) {
        guard !isPaused else { return }

        lastInferenceFrameIndex = snapshot.frameIndex
        let isTracking = snapshot.objects.contains(where: { $0.confidence > 0.3 })
        detectorStateText = isTracking ? "TRACK" : "LOCK"
        statusMessage = snapshot.summary
        lastFrameStatusUpdateTimestamp = snapshot.timestamp

        applyVisionDetections(snapshot)
        accumulateHeatMap()
        syncDetectionEvents()
    }

    private func applyVisionDetections(_ snapshot: VisionDetectionSnapshot) {
        guard detections.count == Self.seedDetections.count else {
            detections = Self.seedDetections
            return
        }

        let strongestByLabel = Dictionary(grouping: snapshot.objects, by: \.label)
            .compactMapValues { objects in
                objects.max { $0.confidence < $1.confidence }
            }

        for idx in detections.indices {
            let label = detections[idx].label
            let strongest = strongestByLabel[label]
            let targetConfidence = strongest?.confidence ?? 0
            // Keep detections stable for brief misses while still responding quickly to new detections.
            let confidenceBlend = strongest == nil ? 0.10 : 0.34
            detections[idx].confidence = lerp(detections[idx].confidence, targetConfidence, by: confidenceBlend)
            guard let rect = strongest?.rect else { continue }
            detections[idx].rect = lerp(detections[idx].rect, normalizedHUDRect(rect), by: 0.2)
        }

        sceneDetections = snapshot.objects
            .sorted { $0.confidence > $1.confidence }
            .prefix(20)
            .map { object in
                HUDDetection(
                    label: object.label,
                    confidence: object.confidence,
                    rect: normalizedHUDRect(object.rect),
                    color: HUDPalette.color(for: object.label)
                )
            }
    }

    private func normalizedHUDRect(_ rect: CGRect) -> CGRect {
        let width = clamp(rect.width, 0.05, 0.92)
        let height = clamp(rect.height, 0.05, 0.92)
        let x = clamp(rect.origin.x, 0.01, 0.99 - width)
        let y = clamp(rect.origin.y, 0.01, 0.99 - height)
        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func decayHeatMap() {
        for i in heatMap.indices {
            heatMap[i] = max(0, heatMap[i] - 1)
        }
    }

    private func accumulateHeatMap() {
        for detection in activeSceneDetections {
            let cx = detection.rect.midX
            let cy = detection.rect.midY

            let col = min(Self.heatMapColumns - 1, max(0, Int(cx * CGFloat(Self.heatMapColumns))))
            let row = min(Self.heatMapRows - 1, max(0, Int(cy * CGFloat(Self.heatMapRows))))
            let index = row * Self.heatMapColumns + col

            if index < heatMap.count {
                heatMap[index] = min(14, heatMap[index] + 3)
            }
        }
    }

    private func syncDetectionEvents() {
        let currentLabels = Set(activeSceneDetections.map(\.label))
        let entered = currentLabels.subtracting(lastActiveLabels)
        let exited = lastActiveLabels.subtracting(currentLabels)

        for label in entered.sorted() {
            appendEvent(marker: "+", label: label, color: HUDPalette.readyGreen)
        }
        for label in exited.sorted() {
            appendEvent(marker: "-", label: label, color: HUDPalette.hudOrange)
        }

        lastActiveLabels = currentLabels
    }

    private func appendEvent(marker: String, label: String, color: Color) {
        eventLog.insert(makeEvent(marker: marker, label: label, color: color), at: 0)
        if eventLog.count > 60 {
            eventLog = Array(eventLog.prefix(60))
        }
    }

    private func makeEvent(marker: String, label: String, color: Color) -> HUDEvent {
        HUDEvent(time: clockFormatter.string(from: Date()), marker: marker, label: label, color: color)
    }

    private func timestamp(from interval: TimeInterval) -> String {
        let seconds = Int(interval.rounded())
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%d:%02d", minutes, remainder)
    }

    private func effectiveThreshold(for label: String) -> Double {
        let multiplier: Double
        switch label {
        case "person":
            multiplier = 1.0
        case "book":
            multiplier = 0.58
        case "pen":
            multiplier = 0.66
        case "banana":
            multiplier = 0.7
        case "cup":
            multiplier = 0.78
        default:
            multiplier = 0.72
        }
        return max(0.04, threshold * multiplier)
    }

    private func clamp<T: Comparable>(_ value: T, _ lower: T, _ upper: T) -> T {
        min(upper, max(lower, value))
    }

    private func lerp(_ current: Double, _ target: Double, by factor: Double) -> Double {
        current + ((target - current) * factor)
    }

    private func lerp(_ current: CGRect, _ target: CGRect, by factor: CGFloat) -> CGRect {
        CGRect(
            x: current.origin.x + ((target.origin.x - current.origin.x) * factor),
            y: current.origin.y + ((target.origin.y - current.origin.y) * factor),
            width: current.size.width + ((target.size.width - current.size.width) * factor),
            height: current.size.height + ((target.size.height - current.size.height) * factor)
        )
    }
}

private struct NarrationEngine {
    func caption(for detections: [HUDDetection]) -> String {
        let sorted = detections.sorted { $0.confidence > $1.confidence }
        let labels = Set(sorted.map(\.label))
        let nearbyObjects = sorted.filter { $0.label != "person" }.prefix(3).map(\.label)

        guard labels.contains("person") else {
            if nearbyObjects.isEmpty {
                return "No person detected. Monitoring the room for movement."
            }
            return "No person detected. Visible objects: \(humanList(from: nearbyObjects))."
        }

        if nearbyObjects.isEmpty {
            return "Person detected. Scanning for nearby objects."
        }

        return "Person detected with \(humanList(from: nearbyObjects))."
    }

    private func humanList(from items: [String]) -> String {
        let readable = items.map { item in
            switch item {
            case "book": return "books"
            case "pen": return "pens and stationery"
            case "cup": return "a cup or bottle"
            case "banana": return "a banana"
            default: return item
            }
        }

        switch readable.count {
        case 0:
            return "none"
        case 1:
            return readable[0]
        case 2:
            return "\(readable[0]) and \(readable[1])"
        default:
            let leading = readable.dropLast().joined(separator: ", ")
            return "\(leading), and \(readable.last ?? "")"
        }
    }
}

private struct HUDDetection: Identifiable {
    let id = UUID()
    let label: String
    var confidence: Double
    var rect: CGRect
    let color: Color
}

private struct HUDEvent: Identifiable {
    let id = UUID()
    let time: String
    let marker: String
    let label: String
    let color: Color
}

private enum HUDPalette {
    static let panelBackground = LinearGradient(
        colors: [Color(red: 0.1, green: 0.1, blue: 0.11), Color(red: 0.06, green: 0.06, blue: 0.07)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let sidebarCard = Color(red: 0.12, green: 0.125, blue: 0.14).opacity(0.9)
    static let sidebarPrimaryText = Color(red: 0.92, green: 0.94, blue: 0.97)
    static let sidebarSecondaryText = Color(red: 0.73, green: 0.77, blue: 0.83)
    static let sidebarMutedText = Color(red: 0.54, green: 0.58, blue: 0.64)
    static let sidebarDivider = Color.white.opacity(0.14)
    static let sidebarTrack = Color(red: 0.18, green: 0.2, blue: 0.24)
    static let chipInactiveBackground = Color(red: 0.17, green: 0.185, blue: 0.22)
    static let sidebarButtonBackground = Color(red: 0.15, green: 0.16, blue: 0.19)

    static let hudOrange = Color(red: 1, green: 0.4, blue: 0.05)
    static let liveRed = Color(red: 0.93, green: 0.16, blue: 0.18)
    static let accentYellow = Color(red: 0.76, green: 1, blue: 0.12)
    static let neonPurple = Color(red: 0.6, green: 0.1, blue: 1)
    static let readyGreen = Color(red: 0.7, green: 1, blue: 0.1)

    static func color(for label: String) -> Color {
        switch label {
        case "person":
            return hudOrange
        case "book":
            return Color(red: 1.0, green: 0.42, blue: 0.15)
        case "pen":
            return Color(red: 0.79, green: 1.0, blue: 0.14)
        case "cup":
            return Color(red: 1, green: 0.24, blue: 0.08)
        case "banana":
            return Color(red: 0.92, green: 1.0, blue: 0.23)
        default:
            return Color.white
        }
    }
}
