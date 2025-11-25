import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('hi'),
    Locale('ur'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Word Master'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @addWord.
  ///
  /// In en, this message translates to:
  /// **'Add Word'**
  String get addWord;

  /// No description provided for @wordList.
  ///
  /// In en, this message translates to:
  /// **'Word List'**
  String get wordList;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @xp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get xp;

  /// No description provided for @todayWords.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Words'**
  String get todayWords;

  /// No description provided for @word.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get word;

  /// No description provided for @meaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get meaning;

  /// No description provided for @synonym.
  ///
  /// In en, this message translates to:
  /// **'Synonym'**
  String get synonym;

  /// No description provided for @antonym.
  ///
  /// In en, this message translates to:
  /// **'Antonym'**
  String get antonym;

  /// No description provided for @example.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get example;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noWordsFound.
  ///
  /// In en, this message translates to:
  /// **'No words found'**
  String get noWordsFound;

  /// No description provided for @addYourFirstWord.
  ///
  /// In en, this message translates to:
  /// **'Add your first word'**
  String get addYourFirstWord;

  /// No description provided for @swipeUpForMeaning.
  ///
  /// In en, this message translates to:
  /// **'Swipe up for meaning quiz'**
  String get swipeUpForMeaning;

  /// No description provided for @swipeLeftForSynonym.
  ///
  /// In en, this message translates to:
  /// **'Swipe left for synonym quiz'**
  String get swipeLeftForSynonym;

  /// No description provided for @swipeRightForAntonym.
  ///
  /// In en, this message translates to:
  /// **'Swipe right for antonym quiz'**
  String get swipeRightForAntonym;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// No description provided for @exitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit Word Master?'**
  String get exitConfirm;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @wordAdded.
  ///
  /// In en, this message translates to:
  /// **'Word added!'**
  String get wordAdded;

  /// No description provided for @xpEarned.
  ///
  /// In en, this message translates to:
  /// **'XP earned'**
  String get xpEarned;

  /// No description provided for @levelUp.
  ///
  /// In en, this message translates to:
  /// **'LEVEL UP!'**
  String get levelUp;

  /// No description provided for @enterWord.
  ///
  /// In en, this message translates to:
  /// **'Enter word'**
  String get enterWord;

  /// No description provided for @enterMeaning.
  ///
  /// In en, this message translates to:
  /// **'Enter meaning'**
  String get enterMeaning;

  /// No description provided for @enterSynonyms.
  ///
  /// In en, this message translates to:
  /// **'Enter synonyms (comma separated)'**
  String get enterSynonyms;

  /// No description provided for @enterAntonyms.
  ///
  /// In en, this message translates to:
  /// **'Enter antonyms (comma separated)'**
  String get enterAntonyms;

  /// No description provided for @enterExample.
  ///
  /// In en, this message translates to:
  /// **'Enter example sentence'**
  String get enterExample;

  /// No description provided for @selectSource.
  ///
  /// In en, this message translates to:
  /// **'Select source'**
  String get selectSource;

  /// No description provided for @yourLibrary.
  ///
  /// In en, this message translates to:
  /// **'Your Library'**
  String get yourLibrary;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @newWords.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newWords;

  /// No description provided for @mastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get mastered;

  /// No description provided for @searchWords.
  ///
  /// In en, this message translates to:
  /// **'Search words...'**
  String get searchWords;

  /// No description provided for @noWordsToday.
  ///
  /// In en, this message translates to:
  /// **'No words added today'**
  String get noWordsToday;

  /// No description provided for @addFirstWord.
  ///
  /// In en, this message translates to:
  /// **'Add your first word to get started!'**
  String get addFirstWord;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// No description provided for @theAnswerIs.
  ///
  /// In en, this message translates to:
  /// **'The answer is'**
  String get theAnswerIs;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will replace all current data with the backup. This action cannot be undone.'**
  String get restoreConfirm;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup?'**
  String get restoreBackup;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully'**
  String get backupCreated;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully'**
  String get backupRestored;

  /// No description provided for @googleDriveBackup.
  ///
  /// In en, this message translates to:
  /// **'Google Drive backup'**
  String get googleDriveBackup;

  /// No description provided for @dataStoredSecurely.
  ///
  /// In en, this message translates to:
  /// **'Data is stored securely in your Google Drive under \"Word Master Backups\" folder.'**
  String get dataStoredSecurely;

  /// No description provided for @signInToGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Google'**
  String get signInToGoogle;

  /// No description provided for @signInDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your Google account to enable backup and restore functionality.'**
  String get signInDescription;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @backupFound.
  ///
  /// In en, this message translates to:
  /// **'Backup found in Google Drive'**
  String get backupFound;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// No description provided for @addNewWord.
  ///
  /// In en, this message translates to:
  /// **'Add New Word'**
  String get addNewWord;

  /// No description provided for @enterTheNewWord.
  ///
  /// In en, this message translates to:
  /// **'Enter the new word'**
  String get enterTheNewWord;

  /// No description provided for @pleaseEnterAWord.
  ///
  /// In en, this message translates to:
  /// **'Please enter a word'**
  String get pleaseEnterAWord;

  /// No description provided for @autoFocus.
  ///
  /// In en, this message translates to:
  /// **'Auto-focus'**
  String get autoFocus;

  /// No description provided for @wordAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Word added!'**
  String get wordAddedSuccess;

  /// No description provided for @failedToAddWord.
  ///
  /// In en, this message translates to:
  /// **'Failed to add word'**
  String get failedToAddWord;

  /// No description provided for @clearForm.
  ///
  /// In en, this message translates to:
  /// **'Clear form'**
  String get clearForm;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get dayStreak;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @noWordsAvailableForQuiz.
  ///
  /// In en, this message translates to:
  /// **'No words available for quiz'**
  String get noWordsAvailableForQuiz;

  /// No description provided for @thisWordHasNoSynonyms.
  ///
  /// In en, this message translates to:
  /// **'This word has no synonyms available'**
  String get thisWordHasNoSynonyms;

  /// No description provided for @thisWordHasNoAntonyms.
  ///
  /// In en, this message translates to:
  /// **'This word has no antonyms available'**
  String get thisWordHasNoAntonyms;

  /// No description provided for @thisWordHasNoMeaning.
  ///
  /// In en, this message translates to:
  /// **'This word has no meaning available'**
  String get thisWordHasNoMeaning;

  /// No description provided for @failedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get failedToLoadData;

  /// No description provided for @wordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Word updated successfully!'**
  String get wordUpdatedSuccessfully;

  /// No description provided for @failedToSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Failed to save changes'**
  String get failedToSaveChanges;

  /// No description provided for @deleteWord.
  ///
  /// In en, this message translates to:
  /// **'Delete Word'**
  String get deleteWord;

  /// No description provided for @deleteWordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this word?'**
  String get deleteWordConfirm;

  /// No description provided for @wordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Word deleted!'**
  String get wordDeleted;

  /// No description provided for @failedToDeleteWord.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete word'**
  String get failedToDeleteWord;

  /// No description provided for @editWord.
  ///
  /// In en, this message translates to:
  /// **'Edit Word'**
  String get editWord;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @article.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get article;

  /// No description provided for @youtube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get youtube;

  /// No description provided for @conversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get conversation;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @quizCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quiz Completed'**
  String get quizCompleted;

  /// No description provided for @youScored.
  ///
  /// In en, this message translates to:
  /// **'You scored'**
  String get youScored;

  /// No description provided for @outOf.
  ///
  /// In en, this message translates to:
  /// **'out of'**
  String get outOf;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @noMeaningAvailable.
  ///
  /// In en, this message translates to:
  /// **'No meaning available'**
  String get noMeaningAvailable;

  /// No description provided for @youHaveNoAddedWordsToday.
  ///
  /// In en, this message translates to:
  /// **'You have no added words today'**
  String get youHaveNoAddedWordsToday;

  /// No description provided for @meanings.
  ///
  /// In en, this message translates to:
  /// **'Meanings'**
  String get meanings;

  /// No description provided for @meaningsHint.
  ///
  /// In en, this message translates to:
  /// **'An unexpected discovery'**
  String get meaningsHint;

  /// No description provided for @synonymsHint.
  ///
  /// In en, this message translates to:
  /// **'Fortunate, chance'**
  String get synonymsHint;

  /// No description provided for @antonymsHint.
  ///
  /// In en, this message translates to:
  /// **'Planned, intentional'**
  String get antonymsHint;

  /// No description provided for @sentenceHint.
  ///
  /// In en, this message translates to:
  /// **'Use this word in your own sentence'**
  String get sentenceHint;

  /// No description provided for @sourceHint.
  ///
  /// In en, this message translates to:
  /// **'Where did you learn this word?'**
  String get sourceHint;

  /// No description provided for @addWordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Word added! +{xp} XP earned.'**
  String addWordSuccess(int xp);

  /// No description provided for @addWordLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Word added! +{xp} XP earned. 🎉 LEVEL UP!'**
  String addWordLevelUp(int xp);

  /// No description provided for @synonyms.
  ///
  /// In en, this message translates to:
  /// **'Synonyms'**
  String get synonyms;

  /// No description provided for @antonyms.
  ///
  /// In en, this message translates to:
  /// **'Antonyms'**
  String get antonyms;

  /// No description provided for @useInSentence.
  ///
  /// In en, this message translates to:
  /// **'Use in a Sentence'**
  String get useInSentence;

  /// No description provided for @makeItPersonal.
  ///
  /// In en, this message translates to:
  /// **'Make it personal'**
  String get makeItPersonal;

  /// No description provided for @whereDidYouLearnThisWord.
  ///
  /// In en, this message translates to:
  /// **'Where did you learn this word? (Source)'**
  String get whereDidYouLearnThisWord;

  /// No description provided for @chooseSource.
  ///
  /// In en, this message translates to:
  /// **'Choose source'**
  String get chooseSource;

  /// No description provided for @saveWord.
  ///
  /// In en, this message translates to:
  /// **'Save Word'**
  String get saveWord;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noMeaningProvided.
  ///
  /// In en, this message translates to:
  /// **'No meaning provided'**
  String get noMeaningProvided;

  /// No description provided for @noSynonymsAdded.
  ///
  /// In en, this message translates to:
  /// **'No synonyms added'**
  String get noSynonymsAdded;

  /// No description provided for @noAntonymsAdded.
  ///
  /// In en, this message translates to:
  /// **'No antonyms added'**
  String get noAntonymsAdded;

  /// No description provided for @noSourceSpecified.
  ///
  /// In en, this message translates to:
  /// **'No source specified'**
  String get noSourceSpecified;

  /// No description provided for @wordStatistics.
  ///
  /// In en, this message translates to:
  /// **'Word Statistics'**
  String get wordStatistics;

  /// No description provided for @xpEarnedStat.
  ///
  /// In en, this message translates to:
  /// **'XP Earned'**
  String get xpEarnedStat;

  /// No description provided for @levelStat.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelStat;

  /// No description provided for @completeness.
  ///
  /// In en, this message translates to:
  /// **'Completeness'**
  String get completeness;

  /// No description provided for @thisFieldIsRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get thisFieldIsRequired;

  /// No description provided for @pleaseEnterTheMeaning.
  ///
  /// In en, this message translates to:
  /// **'Please enter the meaning'**
  String get pleaseEnterTheMeaning;

  /// No description provided for @whatIsTheMeaningOf.
  ///
  /// In en, this message translates to:
  /// **'What is the meaning of \"{word}\"?'**
  String whatIsTheMeaningOf(String word);

  /// No description provided for @meaningQuiz.
  ///
  /// In en, this message translates to:
  /// **'📖 Meaning Quiz'**
  String get meaningQuiz;

  /// No description provided for @synonymQuiz.
  ///
  /// In en, this message translates to:
  /// **'🔗 Synonym Quiz'**
  String get synonymQuiz;

  /// No description provided for @antonymQuiz.
  ///
  /// In en, this message translates to:
  /// **'⚡ Antonym Quiz'**
  String get antonymQuiz;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String correctAnswer(String answer);

  /// No description provided for @xpEarnedFormat.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String xpEarnedFormat(int xp);

  /// No description provided for @levelUpMessage.
  ///
  /// In en, this message translates to:
  /// **'Level Up! 🎉'**
  String get levelUpMessage;

  /// No description provided for @aboutWordMaster.
  ///
  /// In en, this message translates to:
  /// **'About Word Master'**
  String get aboutWordMaster;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @aboutTheApp.
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get aboutTheApp;

  /// No description provided for @aboutTheAppContent.
  ///
  /// In en, this message translates to:
  /// **'Word Master is your ultimate vocabulary companion designed to help you expand your word knowledge effortlessly. Whether you\'re a student preparing for exams, a professional looking to enhance your communication skills, or simply someone who loves learning new words, Word Master provides the perfect platform to build and maintain your vocabulary.'**
  String get aboutTheAppContent;

  /// No description provided for @keyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get keyFeatures;

  /// No description provided for @keyFeaturesContent.
  ///
  /// In en, this message translates to:
  /// **'• Add and organize your vocabulary words\n• Track your learning progress with XP system\n• Maintain daily learning streaks\n• Review words with interactive quizzes\n• Listen to word pronunciations\n• Categorize words by difficulty levels\n• Dark and light theme support\n• Offline functionality with cloud sync'**
  String get keyFeaturesContent;

  /// No description provided for @ourMission.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get ourMission;

  /// No description provided for @ourMissionContent.
  ///
  /// In en, this message translates to:
  /// **'We believe that a rich vocabulary is the foundation of effective communication. Our mission is to make vocabulary learning engaging, systematic, and rewarding. Through gamification elements like XP points, streaks, and levels, we transform the traditional approach to vocabulary building into an enjoyable journey of discovery.'**
  String get ourMissionContent;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @contactUsContent.
  ///
  /// In en, this message translates to:
  /// **'We\'d love to hear from you! Whether you have feedback, suggestions, or need support, feel free to reach out to us.\n\nEmail: support@wordmaster.com\nWebsite: www.wordmaster.com\nFollow us on social media for updates and tips!'**
  String get contactUsContent;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @creditsContent.
  ///
  /// In en, this message translates to:
  /// **'Word Master is developed with ❤️ using Flutter framework. Special thanks to all the developers for making this app possible.\n\nIcons by Material Design Icons\nFonts by Google Fonts\nBuilt with Flutter & Dart'**
  String get creditsContent;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2024 Word Master'**
  String get copyright;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with 💜 for vocabulary enthusiasts'**
  String get madeWithLove;

  /// No description provided for @backupDescription.
  ///
  /// In en, this message translates to:
  /// **'Backup your vocabulary data to Google Drive and restore it on any device. Your words, progress, streaks, and quiz history will be safely stored in the cloud.'**
  String get backupDescription;

  /// No description provided for @tryAdjustingSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjustingSearch;

  /// No description provided for @startAddingWords.
  ///
  /// In en, this message translates to:
  /// **'Start adding words to build your library'**
  String get startAddingWords;

  /// No description provided for @synCount.
  ///
  /// In en, this message translates to:
  /// **'Syn {count}'**
  String synCount(int count);

  /// No description provided for @antCount.
  ///
  /// In en, this message translates to:
  /// **'Ant {count}'**
  String antCount(int count);

  /// No description provided for @quizTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz {current}/{total}'**
  String quizTitle(int current, int total);

  /// No description provided for @enterTheWord.
  ///
  /// In en, this message translates to:
  /// **'Enter the word'**
  String get enterTheWord;

  /// No description provided for @enterTheMeaning.
  ///
  /// In en, this message translates to:
  /// **'Enter the meaning'**
  String get enterTheMeaning;

  /// No description provided for @enterSynonymsComma.
  ///
  /// In en, this message translates to:
  /// **'Enter synonyms (comma separated)'**
  String get enterSynonymsComma;

  /// No description provided for @enterAntonymsComma.
  ///
  /// In en, this message translates to:
  /// **'Enter antonyms (comma separated)'**
  String get enterAntonymsComma;

  /// No description provided for @whereDidYouLearnThisWordShort.
  ///
  /// In en, this message translates to:
  /// **'Where did you learn this word?'**
  String get whereDidYouLearnThisWordShort;

  /// No description provided for @exampleSentence.
  ///
  /// In en, this message translates to:
  /// **'Example Sentence'**
  String get exampleSentence;

  /// No description provided for @noExampleSentenceProvided.
  ///
  /// In en, this message translates to:
  /// **'No example sentence provided'**
  String get noExampleSentenceProvided;

  /// No description provided for @editWordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editWordTooltip;

  /// No description provided for @cancelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelTooltip;

  /// No description provided for @listenTooltip.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listenTooltip;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Lv'**
  String get levelLabel;

  /// No description provided for @synLabel.
  ///
  /// In en, this message translates to:
  /// **'Syn'**
  String get synLabel;

  /// No description provided for @antLabel.
  ///
  /// In en, this message translates to:
  /// **'Ant'**
  String get antLabel;

  /// No description provided for @levelLabelWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Lv {level}'**
  String levelLabelWithNumber(int level);

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get seconds;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'hi', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
