/* eslint-disable no-console */
/* eslint-disable import/no-extraneous-dependencies */
const inquirer = require('inquirer');
const yosay = require('yosay');
const memFs = require('mem-fs');
const editor = require('mem-fs-editor');
const replace = require('replace-in-file');

const pwd = process.cwd();

const preProcess = async () => {
  const store = memFs.create();
  const fs = editor.create(store);

  const questions = [
    {
      type: 'list',
      name: 'type',
      message: 'Please choose environment',
      choices: ['staging', 'prod', 'cancel'],
    },
    {
      type: 'confirm',
      name: 'confirm',
      message: 'Are you sure?',
    },
  ];
  const answer = await inquirer.prompt(questions);

  if (answer.type === "cancel") {
    console.log(yosay(`Cancel using env builder system :)`));
    return;
  }

  //   if (answer.confirm) {
  let androidPackageName = answer.type;
  // `android:label="Cicle Staging"` : `android:label="Cicle"`,
  let androidName = `android:label="Cicle"`
  if (answer.type === 'prod') {
    androidPackageName = 'app';
  }

  if (answer.type === 'staging') {
    androidName = `android:label="Cicle Staging"`
  }

  //     const googleFileType = answer.type;
  const root = `${pwd.replace('/env', "")}`;
  const envPath = `${pwd}`;
  const androidAppPath = `${root}/android/app`;
  const srcPath = `${androidAppPath}/src`;
  const javaMainPath = `${srcPath}/main/kotlin/com/example/cicle_mobile_f3`;
  const androidManifestMainPath = `${srcPath}/main/AndroidManifest.xml`;
  const androidManifestDebugPath = `${srcPath}/debug/AndroidManifest.xml`;
  console.log({
    root,
    answer: answer.type,
    envPath,
    androidAppPath,
    srcPath,
    javaMainPath,
    pwd,
    androidManifestMainPath,
    androidManifestDebugPath
  })

  // Change .env
  fs.copy(`${envPath}/.env.${answer.type}`, `${root}/.env`);
  fs.commit(() => fsCallback('success change .env'));

  // Copy android google-service.json
  fs.copy(
    `${envPath}/google-services.${answer.type}.json`,
    `${androidAppPath}/google-services.json`,
  );
  fs.commit(() => fsCallback('success change google-service.json'));

  // Copy ios google-service.plist
  fs.copy(
    `${envPath}/GoogleService-Info.${answer.type}.plist`,
    `${root}/ios/GoogleService-Info.plist`,
  );
  fs.commit(() => fsCallback('success change google-service.plist'));

  // Copy my-release-key.keystore
  fs.copy(
    `${envPath}/android/my-release-key.${answer.type}.keystore`,
    `${androidAppPath}/my-release-key.keystore`,
  );
  fs.commit(() => fsCallback('success change my-release-key.keystore'));

  try {
    const replaceAndroid = await replace({
      files: [
        androidManifestDebugPath,// replace package id on android/app/src/debug/AndroidManifest.xml
        androidManifestMainPath,// replace package id on android/app/src/main/AndroidManifest.xml
        `${srcPath}/profile/AndroidManifest.xml`,// replace package id on android/app/src/profile/AndroidManifest.xml
        `${javaMainPath}/MainActivity.kt`,// replace package id on android/app/src/main/kotlin/com/example/cicle_v2/MainActivity.kt
        `${androidAppPath}/build.gradle`// replace package id on android/app/build.gradle
      ],
      // from: /(|staging|app).project_multiple_env/g,
      from: /app.cicle|staging.cicle/g,
      to: `${androidPackageName}.cicle`,
      countMatches: true,
    });
    console.log('Replace android package done', replaceAndroid);
    const replaceAndroidName = await replace({
      files: [
        androidManifestMainPath
      ],
      from: answer.type === 'prod' ? `android:label="Cicle Staging"` : `android:label="Cicle"`,
      to: `${androidName}`,
      countMatches: true,
    });
    console.log(`Replace android name to ${androidName} done`, replaceAndroidName);
  } catch (error) {
    console.log('Error replace package', error);
  }

  //     // Replace package name according to the env type
  //     try {
  //       const replaceAndroid = await replace({
  //         files: [
  //           `${javaMainPath}/MainActivity.java`,
  //           `${javaMainPath}/MainApplication.java`,
  //           // `${javaMainPath}/SplashActivity.java`,
  //           // `${javaDebugPath}/ReactNativeFlipper.java`,
  //           `${srcPath}/main/AndroidManifest.xml`,
  //           `${androidAppPath}/build.gradle`,
  //         ],
  //         // from: /(|staging|app).project_multiple_env/g,
  //         from: /app.cicle|staging.cicle/g,
  //         to: `${androidPackageName}.cicle`,
  //         countMatches: true,
  //       });
  //       console.log('Replace android package done', replaceAndroid);
  //       const replaceAndroidName = await replace({
  //         files: [
  //           `${srcPath}/main/res/values/strings.xml`,
  //         ],
  //         from: answer.type === 'staging' ? `<string name="app_name">Cicle</string>` : `<string name="app_name">Cicle Staging</string>`,
  //         to: `${androidName}`,
  //         countMatches: true,
  //       });
  //       console.log(`Replace android name to ${androidName} done`, replaceAndroidName);
  //       console.log('iOS no need for change package')
  //     } catch (e) {
  //       console.log('Error replace package', e);
  //     }
  //   }

  console.log('\n');
  console.log(yosay(`Success generate env for ${answer.type}, Thanks for using env builder system :)`));
};

const fsCallback = (message = 'success') => console.log(message);

const init = () => {
  console.log(yosay('CICLE PLATFORM. Env builder system!!'));
  preProcess();
};

init();
