import Combine
import Foundation

@MainActor
final class DataManager :ObservableObject {
    let bluethoothCentralManager: BluethoothCentralManager
    private var cancellables = Set<AnyCancellable>()
    @Published var carv2DataPair : Carv2DataPair
    
    init(bluethoothCentralManager: BluethoothCentralManager,carv2DataPair: Carv2DataPair) {
        self.bluethoothCentralManager = bluethoothCentralManager
        self.carv2DataPair = carv2DataPair
        subscribe()
    }
    
    func subscribe() {
        bluethoothCentralManager.$carv2DeviceLeft
            .combineLatest(bluethoothCentralManager.$carv2DeviceRight)
            .compactMap { left, right in
                left.flatMap { l in right.map { r in (l, r) } }
            }
            .flatMap { left, right in
                left.$data
                    .compactMap { $0 }
                    .combineLatest(right.$data.compactMap { $0 })
                    .map { leftData, rightData in
                        Carv2DataPair(left: Carv2Data(leftData), right: Carv2Data(rightData))
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .assign(to: \.carv2DataPair, on: self)
            .store(in: &cancellables)
    }
    
}
