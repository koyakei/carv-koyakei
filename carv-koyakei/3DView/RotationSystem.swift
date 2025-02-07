//
//  RotationSystem.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/07.
//

import UIKit
import RealityFoundation
import Spatial
import Combine

struct DynamicRotationComponent: Component {
    var targetRotation: Rotation3D
}

// カスタムシステム
struct RotationSystem: System {
    private static let query = EntityQuery(where: .has(DynamicRotationComponent.self))
    
    init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard let model = entity as? ModelEntity,
                  var component = model.components[DynamicRotationComponent.self]
            else { return }
            
            let newRotation = simd_quatf(component.targetRotation)
            model.transform.rotation = newRotation
            model.components.remove(DynamicRotationComponent.self)
        }
    }
}


class RotationController {
    var cancellables = Set<AnyCancellable>()
    private weak var entity: ModelEntity?  // 追加: 弱参照でEntityを保持
    
    // 追加: イニシャライザでEntityを受け取る
    init(entity: ModelEntity) {
        self.entity = entity
    }
    
    func bind(rotationPublisher: AnyPublisher<Rotation3D, Never>) {
        rotationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rotation in
                guard let self = self,
                      let entity = self.entity else { return }
                
                let quaternion = simd_quatf(from: rotation.vector)
                entity.transform.rotation = quaternion  // entityへの直接アクセス
            }
            .store(in: &cancellables)
    }
}

