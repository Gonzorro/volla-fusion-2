using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(Projectile))]
public class ProjectileEditor : Editor
{
    //private SerializedProperty punchGestureRefsProp;
    //private SerializedProperty upperCutGestureRefsProp;

    //private void OnEnable()
    //{
    //    punchGestureRefsProp = serializedObject.FindProperty("PunchGestureRefs");
    //    upperCutGestureRefsProp = serializedObject.FindProperty("UpperCutGestureRefs");
    //}

    //public override void OnInspectorGUI()
    //{
    //    serializedObject.Update();

    //    // Drawing the properties excluding the manually handled ones
    //    DrawPropertiesExcluding(serializedObject, "m_MonoScript", "PunchGestureRefs", "UpperCutGestureRefs");

    //    EditorGUILayout.Space();
    //    EditorGUILayout.LabelField("Gesture References", EditorStyles.boldLabel);

    //    // Set GUI color to red for Punch Gesture References label
    //    GUI.color = Color.red;
    //    EditorGUILayout.LabelField("Punch Gesture References", EditorStyles.boldLabel);
    //    GUI.color = Color.white; // Resetting GUI color to white (default)
    //    EditProjectileComponentsProperty(punchGestureRefsProp);

    //    EditorGUILayout.Space();

    //    // Set GUI color to red for Upper Cut Gesture References label
    //    GUI.color = Color.red;
    //    EditorGUILayout.LabelField("Upper Cut Gesture References", EditorStyles.boldLabel);
    //    GUI.color = Color.white; // Resetting GUI color to white (default)
    //    EditProjectileComponentsProperty(upperCutGestureRefsProp);

    //    serializedObject.ApplyModifiedProperties();
    //}

    //private void EditProjectileComponentsProperty(SerializedProperty projectileComponentsProp)
    //{
    //    EditorGUILayout.PropertyField(projectileComponentsProp.FindPropertyRelative("collider"), new GUIContent("Collider"));
    //    EditorGUILayout.Space();

    //    EditorGUILayout.PropertyField(projectileComponentsProp.FindPropertyRelative("ParentGesture"), new GUIContent("Parent Gesture", "Parent gesture, should be disable on Inspector"));
    //    EditorGUILayout.PropertyField(projectileComponentsProp.FindPropertyRelative("GestureParticle"), new GUIContent("Gesture Particle", "Parent of main gesture Particle-System, should be the only enabled object.\n Scale Should be Vector3.one"));
    //    EditorGUILayout.Space();

    //    SerializedProperty muzzleTupleProp = projectileComponentsProp.FindPropertyRelative("MuzzleTuple");
    //    EditorGUILayout.PropertyField(muzzleTupleProp.FindPropertyRelative("ParentGameObject"), new GUIContent("Muzzle GameObject", "Parent object of Particle, Should be disabled"));
    //    EditorGUILayout.PropertyField(muzzleTupleProp.FindPropertyRelative("ParticleSystem"), new GUIContent("Muzzle Particle System", "Particle, Should be enabled"));
    //    EditorGUILayout.Space();

    //    SerializedProperty collisionTupleProp = projectileComponentsProp.FindPropertyRelative("CollisionTuple");
    //    EditorGUILayout.PropertyField(collisionTupleProp.FindPropertyRelative("ParentGameObject"), new GUIContent("Collision GameObject", "Parent object of Particle, Should be disabled"));
    //    EditorGUILayout.PropertyField(collisionTupleProp.FindPropertyRelative("ParticleSystem"), new GUIContent("Collision Particle System", "Particle, Should be enabled"));

    //    EditorGUILayout.Space();
    //}
}
