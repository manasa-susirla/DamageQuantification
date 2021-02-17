//
//  ViewController.swift
//
//  Created by Vaibhav, Trijala, Manasa, Sanjay - 12/01/2020
//

import UIKit
import ARKit

//-----------------------
//MARK: ARSCNViewDelegate
//-----------------------

extension ViewController: ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        //3. Update Our Status View
        DispatchQueue.main.async {
            
            //1. Update The Tracking Status
            self.statusLabel.text = self.augmentedRealitySession.sessionStatus()
            
            //2. If We Have Nothing To Report Then Hide The Status View & Shift The Settings Menu
            if let validSessionText = self.statusLabel.text{
                
                self.sessionLabelView.isHidden = validSessionText.isEmpty
            }
            
            if self.sessionLabelView.isHidden { self.settingsConstraint.constant = 26 } else { self.settingsConstraint.constant = 0 }
           
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        let meshNode : SCNNode
        let textNode : SCNNode
        let extentNode: SCNNode

        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}

        
        guard let meshGeometry = ARSCNPlaneGeometry(device: augmentedRealityView.device!)
            else {
                fatalError("Can't create plane geometry")
        }
        
        let extentPlane: SCNPlane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        extentNode = SCNNode(geometry: extentPlane)
        extentNode.simdPosition = planeAnchor.center
        
        
        extentNode.eulerAngles.x = -.pi / 2
        
        extentNode.opacity = 0.6

        guard let material = extentNode.geometry?.firstMaterial
            else { fatalError("SCNPlane always has one material") }
        
        material.diffuse.contents = UIColor.systemYellow

        // Use a SceneKit shader modifier to render only the borders of the plane.
        guard let path = Bundle.main.path(forResource: "wireframe_shader", ofType: "metal", inDirectory: "Assets.scnassets")
            else { fatalError("Can't find wireframe shader") }
        do {
            let shader = try String(contentsOfFile: path, encoding: .utf8)
            material.shaderModifiers = [.surface: shader]
        } catch {
            fatalError("Can't load wireframe shader: \(error)")
        }

        
        meshGeometry.update(from: planeAnchor.geometry)
        meshNode = SCNNode(geometry: meshGeometry)
        meshNode.name = "MeshNode"
        meshNode.opacity = 0.25
        
        // Use color and blend mode to make planes stand out.
        guard let materialGeo = meshNode.geometry?.firstMaterial
            else { fatalError("ARSCNPlaneGeometry always has one material") }
        materialGeo.diffuse.contents = UIColor.systemYellow
        
//        material.diffuse.contents = UIColor.clear
        
      //  node.addChildNode(meshNode)
        
        let textGeometry = SCNText(string: "Plane", extrusionDepth: 1)
        textGeometry.font = UIFont(name: "Futura", size: 75)
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.name = "TextNode"
        
        textNode.simdScale = SIMD3(repeating: 0.0005)
        textNode.eulerAngles = SCNVector3(x: Float(-90.degreesToradians), y: 0, z: 0)
        
       // super.init()

        
        node.addChildNode(textNode)
        // Add the plane extent and plane geometry as child nodes so they appear in the scene.
        node.addChildNode(meshNode)
        node.addChildNode(extentNode)
        textNode.centerAlign()
        
        
        print("did add plane node")
        
    }
}

class ViewController: UIViewController {

    //1. Create A Reference To Our ARSCNView In Our Storyboard Which Displays The Camera Feed
    @IBOutlet weak var augmentedRealityView: ARSCNView!
    
    @IBOutlet weak var topbackgroundview: UIView!
    //2. Create A Reference To Our ARSCNView In Our Storyboard Which Will Display The ARSession Tracking Status
    @IBOutlet weak var sessionLabelView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    //3. Create Our ARWorld Tracking Configuration
    let configuration = ARWorldTrackingConfiguration()
    
    //4. Create Our Session
    let augmentedRealitySession = ARSession()

    //5. Create Arrays To Store All The Nodes Placed
    var nodesAdded = [SCNNode]()
    var angleNodes = [SCNNode]()
    var distanceNodes = [SCNNode]()
    var lineNodes = [SCNNode]()
    var showDistanceLabels = true
    var showAngleLabels = false
    
    
    var savedAlert: UIAlertController!

    //6. Create A Variable Which Determines Whether The User Wants To Join The Last & First Markers Together
    var joiningNodes = false
    
    //7. Create An Array Of UILabels Which Will Display Our Length In Different Units
    @IBOutlet var measurementLabels: [UILabel]!
    @IBOutlet var unitHolder: UIView!
    
    //8. Settings Menu
    @IBOutlet var settingsMenu: UIView!
    @IBOutlet var settingsConstraint: NSLayoutConstraint!
    @IBOutlet var planeDetectionController: UISegmentedControl!
    @IBOutlet var festurePointController: UISegmentedControl!
    @IBOutlet var showAnglesController: UISegmentedControl!
    @IBOutlet var showDistanceController: UISegmentedControl!
    var settingsMenuShown = false
    
    //9. Variables To Determine If We Are Placing Our Markers On Detected Planes Or Feature Points
    var placeOnPlane = false
    var showFeaturePoints = false
    var placementType: ARHitTestResult.ResultType = .featurePoint
    
    @IBOutlet weak var undoButton: UIButton!
    //--------------------
    //MARK: View LifeCycle
    //--------------------
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        clearMeasurementLabels()
        
       // self.topbackgroundview.layer.zPosition = -1
        
    }
    
    override func viewDidAppear(_ animated: Bool) { setupARSession() }
    
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    //-------------
    //MARK: Actions
    //-------------
    
    /// Closes All The Node Markers To Form A Shape
    @IBAction func closeMarkers(){ closeNodes() }
    
    /// Removes All Measurement Data
    @IBAction func reset(){
        
        //1. Remove All Nodes From The Hierachy
        augmentedRealityView.scene.rootNode.enumerateChildNodes { (nodeToRemove, _) in nodeToRemove.removeFromParentNode() }
        
        //2. Clear The NodesAdded Array
        nodesAdded.removeAll()
        angleNodes.removeAll()
        distanceNodes.removeAll()
        lineNodes.removeAll()
        
        //3. Reset The Joining Boolean
        joiningNodes = false
        
        //4. Reset The Labels
        clearMeasurementLabels()
        settingsMenu.alpha = 0
        settingsMenuShown = false
    }
    
    //--------------
    //MARK: Settings
    //--------------

    /// Shows And Hides The Settings Menu

    @IBAction func undo(){
        var count = 0
        augmentedRealityView.scene.rootNode.enumerateChildNodes { (nodeToRemove, _) in count+=1 }
        var close = 0
        print("-------")
        print(count)
        print("-------")
        augmentedRealityView.scene.rootNode.enumerateChildNodes { (nodeToRemove, _) in if close<=count && close>count-7 {
            print(close)
            
            nodeToRemove.removeFromParentNode();
            close+=1;
        }else{
            close+=1;
        }}
        //print(count)
        if !nodesAdded.isEmpty{
            nodesAdded.removeLast()
        }
        if !angleNodes.isEmpty{
            angleNodes.removeLast()
        }
        if !distanceNodes.isEmpty{
            distanceNodes.removeLast()
        }
        if !lineNodes.isEmpty{
            lineNodes.removeLast()
        }
        
        
        //3. Reset The Joining Boolean
        joiningNodes = false
        
        //4. Reset The Labels
        clearMeasurementLabels()
        settingsMenu.alpha = 0
        settingsMenuShown = false
    }
    
    @IBAction func bounce(){
        nodesAdded.removeAll()
        angleNodes.removeAll()
        distanceNodes.removeAll()
        lineNodes.removeAll()
        
        //3. Reset The Joining Boolean
        joiningNodes = false
        
        //4. Reset The Labels
        clearMeasurementLabels()
        settingsMenu.alpha = 0
        settingsMenuShown = false
    }
    
    @IBAction func showSettingsMenu(){
        var opacity: CGFloat = 0
        var angleOpacity: CGFloat = 0
        var markerOpacity: CGFloat = 0
        
        if settingsMenu.alpha == 0 {
            
            settingsMenu.alpha = 1
            settingsMenuShown = true
            augmentedRealityView.rippleView()
            
        } else {
            
            settingsMenu.alpha = 0
            settingsMenuShown = false
            opacity = 1
            
            if showAngleLabels { angleOpacity = 1 }
            if showDistanceLabels { markerOpacity = 1 }
            
        }
        
        setNodesVisibility(angleNodes, opacity: angleOpacity)
        setNodesVisibility(distanceNodes, opacity: markerOpacity)
        let markerAndLineNodes = lineNodes + nodesAdded
        setNodesVisibility(markerAndLineNodes, opacity: opacity)
    }
    
    /// Hides The 3D Distance Labels
    ///
    /// - Parameter controller: UISegmentedControl
    @IBAction func hideDistanceLabels(_ controller: UISegmentedControl){
   
        if controller.selectedSegmentIndex != 1 {
            
            showDistanceLabels = true
            
        }else{
            
            showDistanceLabels = false
        }
        
    }
    
    /// Hides The 3D Angle Labels
    ///
    /// - Parameter controller: UISegmentedControl
    @IBAction func hideAngleLabels(_ controller: UISegmentedControl){
        

        if controller.selectedSegmentIndex != 1 {
            
            showAngleLabels = true
            
        }else{
            showAngleLabels = false
        }
            
    }
    
    /// Determines Whether The VideoNode Should Be Placed Using Plane Detection
    ///
    /// - Parameter controller: UISegmentedControl
    @IBAction func setPlaneDetection(_ controller: UISegmentedControl){
        
        if controller.selectedSegmentIndex == 1 { placeOnPlane = false } else { placeOnPlane = true }
        
        setupSessionPreferences()
    }
    
    /// Determines Whether The User Should Be Able To See FeaturePoints
    ///
    /// - Parameter controller: UISegmentedControl
    @IBAction func setFeaturePoints(_ controller: UISegmentedControl){
        
        if controller.selectedSegmentIndex == 1 { showFeaturePoints = false } else { showFeaturePoints = true }
        setupSessionPreferences()
    }
    
    //----------------------
    //MARK: Marker Placement
    //----------------------
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if joiningNodes { reset() }
        
        if settingsMenuShown { return }
        
        //1. Perform An ARHitTest To Search For Any Existing Planes Or Feature Points
        if placeOnPlane { placementType = .existingPlane } else { placementType = .featurePoint }
        
        //2. Get The Current Touch Location & Perform An ARHitTest
        guard let currentTouchLocation = touches.first?.location(in: self.augmentedRealityView),
              let hitTest = self.augmentedRealityView.hitTest(currentTouchLocation, types: placementType ).last else { return }
        
        //3. Add A Marker Node
        addMarkerNodeFromMatrix(hitTest.worldTransform)
        
    }
    

    /// Adds An SCNSphere At The Current Touch Location
    ///
    /// - Parameter matrix: matrix_float4x4
    func addMarkerNodeFromMatrix(_ matrix: matrix_float4x4){
    
        //1. Create The Marker Node & Add It  To The Scene
        let markerNode = MarkerNode(fromMatrix: matrix)
        self.augmentedRealityView.scene.rootNode.addChildNode(markerNode)
        
        //3. Add It To Our NodesAdded Array
        nodesAdded.append(markerNode)
        
        //4. Perform Any Calculations Needed
        getDistanceBetweenNodes(needsJoining: joiningNodes)
    
        guard let angleResult = calculateAnglesBetweenNodes(joiningNodes: joiningNodes, nodes: nodesAdded) else { return }
        createAngleNodeLabelOn(angleResult.midNode, angle: angleResult.angle)

    }
    
    /// Joins The Last & First Nodes
    func closeNodes(){
    
        joiningNodes = true
        getDistanceBetweenNodes(needsJoining: joiningNodes)
        
        guard let angleResult = calculateAnglesBetweenNodes(joiningNodes: joiningNodes, nodes: nodesAdded) else { return }
        createAngleNodeLabelOn(angleResult.midNode, angle: angleResult.angle)
        
        guard let angleResultB = calculateFinalAnglesBetweenNodes(nodesAdded) else { return }
        createAngleNodeLabelOn(angleResultB.midNode, angle: angleResultB.angle)
     
    }
    
    //-------------------------------------------
    //MARK: Calculation + Distance & Angle Labels
    //-------------------------------------------
    
    /// Calculates The Distance Between 2 SCNNodes
    func getDistanceBetweenNodes(needsJoining: Bool){
        
        //1. If We Have More Than Two Nodes On Screen We Can Calculate The Distance Between Them
        if nodesAdded.count >= 2{
            
            guard let result = calculateDistanceBetweenNodes(joiningNodes: needsJoining, nodes: nodesAdded) else { return }
            
            //2. Draw A Line Between The Nodes
            let line = MeasuringLineNode(startingVector: result.nodeA, endingVector: result.nodeB)
            self.augmentedRealityView.scene.rootNode.addChildNode(line)
            lineNodes.append(line)
//            let centimeters = Measurement(value: Double(result.distance), unit: UnitLength.centimeters)
//            print("Distance Between Markers Nodes = \(String(format: "%.2f", centimeters.value))cm")
            //3. Create The Distance Label
            createDistanceLabel(joiningNodes: needsJoining, nodes: nodesAdded, distance: result.distance)
        }
        
    }
    
    /// Creates An Angle Label Between Three SCNNodes
    ///
    /// - Parameters:
    ///   - node: SCNNode
    ///   - angle: Double
    func createAngleNodeLabelOn(_ node: SCNNode, angle: Double){
        
        //1. Format Our Angle
        let formattedAngle = String(format: "%.2f°", angle)
        
        //2. Create The Angle Label & Add It To The Corresponding Node
        let angleText = TextNode(text: formattedAngle, colour: .white)
        angleText.position = SCNVector3(0, 0.01, 0)
        node.addChildNode(angleText)
        
        //3. Store It
        angleNodes.append(angleText)
        
        var opacity: CGFloat = 0
        
        if showAngleLabels { opacity = 1 }
        setNodesVisibility(angleNodes, opacity: opacity)
    }
    
    /// Clears The Measurement Labels
    func clearMeasurementLabels(){
        
        measurementLabels.forEach{ $0.text = "" }
        unitHolder.alpha = 0
    }
    
    /// Creates A Distance Label Between Two SCNNodes
    ///
    /// - Parameters:
    ///   - joiningNodes: Bool (Joins The Last Node Added To The First)
    ///   - nodes: [SCNNode]
    ///   - distance: Float
    func createDistanceLabel(joiningNodes: Bool, nodes: [SCNNode], distance: Float){
        
        //1. Get The Nodes Used For Postioning
        guard let nodes = positionalNodes(joiningNodes: joiningNodes, nodes: nodes) else { return }
        let nodeA = nodes.nodeA
        let nodeB = nodes.nodeB
        
        //2. Format Our Angle
        let m = Measurement(value: Double(distance), unit: UnitLength.meters)
       // let cm = m.converted(to: UnitLength.centimeters)
        let inches = m.converted(to: UnitLength.inches)
        let formattedDistance = "\(String(format: "%.2f", inches.value))in"
        let distanceLabel = LabelNode(formattedDistance, textColor: .black)
//        if(placeOnPlane){
//             formattedDistance = "\(String(format: "%.2f", inches.value))in"
//
//        }
//        else{
//            formattedDistance = "\(String(format: "%.2f", (inches.value)+1.5))in"
//        }
        let maxPosition = nodeB.position
        let minPosition = nodeA.position
        let dx = ((maxPosition.x + minPosition.x)/2.0)
        let dy = (maxPosition.y + minPosition.y)/2.0 + 0.01
        let dz = (maxPosition.z + minPosition.z)/2.0

        let centerPoint = SCNVector3(dx, dy, dz)
        

        

       // print("Distance Between Markers Nodes = \(String(format: "%.2f", meters.value))m")

      //  let worldPos = augmentedRealityView?.realWorldVector(screenPos: view.center)
        let currentCameraPosition = augmentedRealityView.pointOfView!
        
        let distanceBetweenNodeAndCamera = centerPoint.distance(from: currentCameraPosition.worldPosition)
        
        let delta = Float(distanceBetweenNodeAndCamera * 3.5)
//        let distanceLabel = LabelNode(formattedDistance, textColor: .black)

       // print("Distance Between Markers Nodes = \(String(format: "%.2f", meters.value))m")

        //4. Create The Distance Label & Add It To The Scene
//        let currentCameraPosition = augmentedRealityView.pointOfView
//        let distanceBetweenNodeAndCamera = simd_distance(distanceLabel.simdTransform.columns.3, (augmentedRealityView.session.currentFrame?.camera.transform.columns.3)!);
//        var delta = Float(distanceBetweenNodeAndCamera * 7)
//        if(distanceBetweenNodeAndCamera<0.025){
//            delta = Float(distanceBetweenNodeAndCamera * 500)
//        }
//        if(distanceBetweenNodeAndCamera<0.05 && distanceBetweenNodeAndCamera>0.025){
//            delta = Float(distanceBetweenNodeAndCamera * 50)
//        }
//        if(distanceBetweenNodeAndCamera<0.10 && distanceBetweenNodeAndCamera>0.05){
//            delta = Float(distanceBetweenNodeAndCamera * 35)
//        }
//        if(distanceBetweenNodeAndCamera<0.18 && distanceBetweenNodeAndCamera>0.10){
//            delta = Float(distanceBetweenNodeAndCamera * 24)
//        }
//        if(distanceBetweenNodeAndCamera<0.25 && distanceBetweenNodeAndCamera>0.18){
//            delta = Float(distanceBetweenNodeAndCamera * 17)
//        }
//        if(distanceBetweenNodeAndCamera<0.35 && distanceBetweenNodeAndCamera>0.25){
//            delta = Float(distanceBetweenNodeAndCamera * 15)
//        }
//        if(distanceBetweenNodeAndCamera<0.50 && distanceBetweenNodeAndCamera>0.35){
//            delta = Float(distanceBetweenNodeAndCamera * 12)
//        }
//        if(distanceBetweenNodeAndCamera<0.70 && distanceBetweenNodeAndCamera>0.50){
//            delta = Float(distanceBetweenNodeAndCamera * 8)
//        }
//        if(distanceBetweenNodeAndCamera<0.9 && distanceBetweenNodeAndCamera>0.7){
//            delta = Float(distanceBetweenNodeAndCamera * 6)
//        }
//        if( distanceBetweenNodeAndCamera<1.75 && distanceBetweenNodeAndCamera>0.9){
//            delta = Float(distanceBetweenNodeAndCamera * 4)
//        }
//        if( distanceBetweenNodeAndCamera<3 && distanceBetweenNodeAndCamera>1.75){
//            delta = Float(distanceBetweenNodeAndCamera * 2)
//        }
//        if(  distanceBetweenNodeAndCamera>3){
//            delta = Float(distanceBetweenNodeAndCamera * 1.25)
//        }
//        print(distanceBetweenNodeAndCamera)
//        distanceLabel.placeBetweenNodesLabel(nodeA, and: nodeB)
////        distanceLabel.simdScale = simd_float3(delta, delta, delta)
//        self.augmentedRealityView.scene.rootNode.addChildNode(distanceLabel)
        distanceLabel.position = SCNVector3(dx, dy, dz)
        distanceLabel.simdScale = simd_float3(delta, delta, delta)
        self.augmentedRealityView.scene.rootNode.addChildNode(distanceLabel)
        
        //5. Generate The Measurement Labels
        generateMeasurementLabelsFrom(distance)
        
        //6. Store It
        distanceNodes.append(distanceLabel)
        
        var opacity: CGFloat = 0
        
        if showDistanceLabels { opacity = 1 }
        setNodesVisibility(distanceNodes, opacity: opacity)
    }
    
    func generateMeasurementLabelsFrom(_ distanceInMetres: Float){
        
        let sequence = stride(from: 0, to: 5, by: 1)
        let measurements = convertedLengthsFromMetres(distanceInMetres)
    
        let suffixes = ["m", "cm", "mm", "ft", "in"]
        
        for index in sequence {
         
            let labelToDisplay = measurementLabels[index]
            let value = "\(String(format: "%.2f", measurements[index].value))\(suffixes[index])"
            labelToDisplay.text = value
        }
        
        unitHolder.alpha = 1
        
    }
    
    //---------------------
    //MARK: Node Visibility
    //---------------------
    
    
    /// Sets The Visibility Of The Angle & Distance Text Nodes
    ///
    /// - Parameters:
    ///   - nodes: [SCNNode]
    ///   - opacity: CGFloat
    func setNodesVisibility(_ nodes: [SCNNode], opacity: CGFloat) {
        
        nodes.forEach { (node) in node.opacity = opacity }
    
    }
    
    //---------------
    //MARK: ARSession
    //---------------
    
    /// Sets Up The ARSession
    func setupARSession(){
        
        //1. Set The AR Session
        augmentedRealityView.session = augmentedRealitySession
        augmentedRealityView.delegate = self
        setupSessionPreferences()
        
    }
    
    /// Runs The ARSessionConfiguration Based On The Preferences Chosen
    func setupSessionPreferences(){
        
        configuration.planeDetection = [planeDetection(.None)]
        augmentedRealityView.debugOptions = debug(.None)
        
        if placeOnPlane { configuration.planeDetection = [planeDetection(.Both)] }
        
        if showFeaturePoints { augmentedRealityView.debugOptions = debug(.FeaturePoints) }
        
        //4. Run The Session & Reset The Video Node
        augmentedRealitySession.run(configuration, options: runOptions(.ResetAndRemove))
        reset()
      
    }
    
    @IBAction func snapshotButtonTapped(_ sender: Any){
             print("Entered snapshot")
             //1. Create A Snapshot
             let snapShot = self.augmentedRealityView.snapshot()
 
             //2. Save It The Photos Album
             UIImageWriteToSavedPhotosAlbum(snapShot, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
             snapshotsavedalert()
 
      }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        if let error = error {
            print("Error Saving ARKit Scene \(error)")
        } else {
            print("ARKit Scene Successfully Saved")
        }
    }
    
    func snapshotsavedalert(){
        savedAlert = UIAlertController(title: "", message: "Image saved successfully",
                                       preferredStyle: .alert)
        present(savedAlert, animated: true, completion: nil)
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
          // your code with delay
            self.savedAlert.dismiss(animated: true, completion: nil)
        }
        //savedAlert.dismiss(animated: true, completion: nil)
    }
 

}
extension SCNNode {
    func centerAlign() {
        let (min, max) = boundingBox
        let extents = ((max) - (min))
        simdPivot = float4x4(translation: SIMD3((extents / 2) + (min)))
    }
}

extension float4x4 {
    init(translation vector: SIMD3<Float>) {
        self.init(SIMD4(1, 0, 0, 0),
                  SIMD4(0, 1, 0, 0),
                  SIMD4(0, 0, 1, 0),
                  SIMD4(vector.x, vector.y, vector.z, 1))
    }
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}
func / (left: SCNVector3, right: Int) -> SCNVector3 {
    return SCNVector3Make(left.x / Float(right), left.y / Float(right), left.z / Float(right))
}
extension Int {
    var degreesToradians : Double {return Double(self) * .pi/180}
}

