allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val setupNamespace = { p: Project ->
        val android = p.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (android != null) {
            if (android.namespace == null) {
                // descope specifically needs com.descope.flutter
                if (p.name == "descope") {
                    android.namespace = "com.descope.flutter"
                } else {
                    android.namespace = "com.${p.name.replace("-", ".")}"
                }
            }
        }
    }

    if (project.state.executed) {
        setupNamespace(project)
    } else {
        project.afterEvaluate { setupNamespace(this) }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
