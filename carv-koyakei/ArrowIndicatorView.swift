//// 再利用可能な矢印インジケーターコンポーネント
//import SwiftUI
//import RealityKit
//import Combine
//import Spatial
//struct ArrowIndicatorView: View {
//    @ObservedObject var dataPair: Carv2DataPair
//    let rotationKeyPath: KeyPath<Carv2Data, Rotation3D>
//    
//    var body: some View {
//        RealityView { content in
//            let arrowEntity = createArrowEntity()
//            let controller = RotationController(entity: arrowEntity)
//            
//            dataPair.objectWillChange
//                .compactMap { [dataPair] in dataPair[keyPath: rotationKeyPath] }
//                .sink { rotation in
//                    controller.updateRotation(rotation)
//                }
//                .store(in: &controller.cancellables)
//            
//            content.add(arrowEntity)
//        }
//        .frame(height: 400)
//    }
//    
//    // 矢印エンティティ生成関数
//    private func createArrowEntity() -> ModelEntity {
//        let arrowEntity = ModelEntity()
//        
//        // 主要コンポーネントの構築（元コードの実装を再利用）
//        let mainShaft = ModelEntity(
//            mesh: .generateCylinder(height: 0.5, radius: 0.03),
//            materials: [SimpleMaterial(color: .blue, isMetallic: true)]
//        )
//        mainShaft.position.y = 0.5
//        
//        // ...（他のパーツの生成コードも同様に保持）
//        
//        return arrowEntity
//    }
//}
//
//
//// 回転制御コントローラー
//class RotationController {
//    private weak var entity: ModelEntity?
//    private var cancellables = Set<AnyCancellable>()
//    
//    init(entity: ModelEntity) {
//        self.entity = entity
//    }
//    
//    func updateRotation(_ rotation: Rotation3D) {
//        entity?.orientation = simd_quatf(rotation)
//    }
//    
//    // Combine購読管理
//    func bind<P: Publisher>(rotationPublisher: P) where P.Output == Rotation3D {
//        rotationPublisher
//            .receive(on: RunLoop.main)
//            .sink { [weak self] rotation in
//                self?.updateRotation(rotation)
//            }
//            .store(in: &cancellables)
//    }
//}
