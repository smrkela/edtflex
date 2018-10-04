package
{
	import com.evola.driving.controls.QuestionLoadingDialog;
	import com.evola.driving.controls.TestResultsControl;
	import com.evola.driving.controls.TimerControl;
	import com.evola.driving.controls.spinner.SpinnerUtil;
	import com.evola.driving.model.DrivingCategory;
	import com.evola.driving.model.Question;
	import com.evola.driving.model.QuestionCategory;
	import com.evola.driving.model.User;
	import com.evola.driving.util.EvolaDrivingModel;
	import com.evola.driving.util.PageManager;
	import com.evola.driving.util.QuestionsParser;
	import com.evola.driving.views.pages.HomePage;

	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.controls.Alert;
	import mx.managers.IBrowserManager;
	import mx.managers.PopUpManager;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.rpc.http.mxml.HTTPService;
	import mx.utils.UIDUtil;

	[Bindable]
	public class CopyOfMainPresenter
	{

		public var model:EvolaDrivingModel=new EvolaDrivingModel();
		public var view:EvolaDrivingTesting;
		public var timerControl:TimerControl;
		public var homePage:HomePage;
		public var browserManager:IBrowserManager;

		//timer za cuvanje zadataka pri ucenju
		private var _learningTimer:Timer;

		public var questionsLoadingDialog:QuestionLoadingDialog;

		public function CopyOfMainPresenter(view:EvolaDrivingTesting)
		{

			this.view=view;
		}

		public function initializeModel(settingsXML:XML, questionFiles:Array):void
		{

			QuestionsParser.fillQuestions(model, settingsXML, questionFiles);
		}

		public function startLearning(dCategory:DrivingCategory, qCategory:QuestionCategory, randomizeQuestions:Boolean, onlyNonLearntQuestions:Boolean, learntQuestionsIds:ArrayCollection):void
		{

			//resetujemo mapu sacuvanih pitanja
			model.learningSavedQuestions={};
			model.learningSessionUID=UIDUtil.createUID();

			var excludedQuestionIds:ArrayCollection=null;

			if (onlyNonLearntQuestions)
				excludedQuestionIds=learntQuestionsIds;

			prepareQuestions(dCategory, qCategory, model.userQuestions.length, randomizeQuestions, excludedQuestionIds, null);

			model.isInProgress=true;
			model.isTestingMode=false;

			PageManager.selectPage("Questions");

			if (timerControl)
				timerControl.start();
		}
		
		public function startLearningSimple():void
		{
			
			//resetujemo mapu sacuvanih pitanja
			model.learningSavedQuestions={};
			model.learningSessionUID=UIDUtil.createUID();
			
			var excludedQuestionIds:ArrayCollection=null;
			
			model.isInProgress=true;
			model.isTestingMode=false;
			
			if (timerControl)
				timerControl.start();
		}

		public function resetTest():void
		{

			for each (var q:Question in model.filteredQuestions)
			{

				q.reset();
			}

			selectFirstPage();
		}

		public function startTesting(dCategory:DrivingCategory, qCategory:QuestionCategory, quickResponse:Boolean, numOfQuestions:int, randomizeQuestions:Boolean, onlyLearntQuestions:Boolean, learntQuestionsIds:ArrayCollection, onlyNonTestedQuestions:Boolean, testedQuestionsIds:ArrayCollection):void
		{

			//resetujemo mapu sacuvanih pitanja
			model.testingSavedQuestions={};
			model.testingSessionUID=UIDUtil.createUID();

			var excludedQuestionIds:ArrayCollection=null;
			var includedQuestionIds:ArrayCollection=null;

			if (onlyLearntQuestions)
				includedQuestionIds=learntQuestionsIds;

			if (onlyNonTestedQuestions)
				excludedQuestionIds=testedQuestionsIds;

			prepareQuestions(dCategory, qCategory, numOfQuestions, randomizeQuestions, excludedQuestionIds, includedQuestionIds);

			model.isInProgress=true;
			model.isTestingMode=true;
			model.useQuickResponse=quickResponse;
			model.testFinished=false;

			PageManager.selectPage("Questions");
			
			if (timerControl)
				timerControl.start();
		}
		
		public function startTestingSimple():void
		{
			
			//resetujemo mapu sacuvanih pitanja
			model.testingSavedQuestions={};
			model.testingSessionUID=UIDUtil.createUID();
			
			model.isInProgress=true;
			model.isTestingMode=true;
			model.useQuickResponse=true;
			model.testFinished=false;
			
			if (timerControl)
				timerControl.start();
		}

		private function prepareQuestions(dCategory:DrivingCategory, qCategory:QuestionCategory, numOfQuestions:int, randomizeQuestions:Boolean, excludedQuestionIds:ArrayCollection, includedQuestionIds:ArrayCollection):void
		{

			model.currentQuestionCategory=qCategory;
			model.currentDrivingCategory=dCategory;
			model.currentNumberOfQuestions=numOfQuestions;
			model.currentRandomizeQuestions=randomizeQuestions;

			//sada treba da pripremimo pitanja za izabrane kategorije
			var filteredQuestions:ArrayCollection=new ArrayCollection();

			for each (var q:Question in model.userQuestions)
			{

				q.reset();

				if (q.isInDrivingCategory(dCategory) && q.isInQuestionCategory(qCategory))
				{

					var isNotExcluded:Boolean=excludedQuestionIds == null || !excludedQuestionIds.contains(q.id);
					var isIncluded:Boolean=includedQuestionIds == null || includedQuestionIds.contains(q.id);

					if (isNotExcluded && isIncluded)
						filteredQuestions.addItem(q);
				}
			}

			//sada radimo shuffle niza ako treba
			if (randomizeQuestions)
			{

				function randomCompare(a:Object, b:Object, fields:Array=null):int
				{
					return Math.round(Math.random() * -1 + Math.random());
				}

				var sort:Sort=new Sort();
				sort.compareFunction=randomCompare;
				filteredQuestions.sort=sort;
				filteredQuestions.refresh();
			}
			else
			{

				function normalCompare(a:Question, b:Question, fields:Array=null):int
				{

					var ci1:Number=a.getQuestionCategoryIndex();
					var ci2:Number=b.getQuestionCategoryIndex();

					//prvo poredimo kategorije
					if (ci1 < ci2)
						return -1;

					if (ci2 < ci1)
						return 1;

					//sada poredimo indexe pitanja
					var qi1:Number=a.getQuestionIndex();
					var qi2:Number=b.getQuestionIndex();

					return qi1 < qi2 ? -1 : 1;
				}

				var sort:Sort=new Sort();
				sort.compareFunction=normalCompare;
				filteredQuestions.sort=sort;
				filteredQuestions.refresh();

			}

			//sada radimo limitiranje na odredjeni broj
			var filteredCount:int=filteredQuestions.length;
			var reducedCollection:ArrayCollection=new ArrayCollection();

			for (var i:int=0; i < filteredCount; i++)
			{

				if (i <= numOfQuestions - 1)
					reducedCollection.addItem(filteredQuestions.getItemAt(i));
			}

			filteredQuestions=reducedCollection;

			//sada imamo spremna sva pitanja
			model.filteredQuestions=filteredQuestions;

			//sada formiramo stranice
			var ac:ArrayCollection=new ArrayCollection();

			var length:int=filteredQuestions.length;
			var lastPage:ArrayCollection;

			for (var i:int=0; i < length; i++)
			{

				if (i % Settings.user.questionsPerPage == 0)
				{

					lastPage=new ArrayCollection();
					ac.addItem(lastPage);
				}

				lastPage.addItem(filteredQuestions.getItemAt(i));
			}

			model.currentQuestionPages=ac;
			selectPage(ac.getItemAt(0) as ArrayCollection);
		}

		public function selectPage(questions:ArrayCollection):void
		{
			model.currentQuestions=questions;

			if (questions.length > 0)
				selectQuestion(questions.getItemAt(0) as Question);
		}

		public function selectFirstPage():void
		{
			if (totalQuestionPages > 0)
				selectPage(model.currentQuestionPages.getItemAt(0) as ArrayCollection);
		}

		public function selectPreviousPage():void
		{
			if (totalQuestionPages > 0)
			{
				var currentIndex:int=model.currentQuestionPages.getItemIndex(model.currentQuestions);

				if (currentIndex > 0)
					selectPage(model.currentQuestionPages.getItemAt(currentIndex - 1) as ArrayCollection);
			}
		}

		public function selectNextPage():void
		{
			if (totalQuestionPages > 0)
			{
				var currentIndex:int=model.currentQuestionPages.getItemIndex(model.currentQuestions);

				if (currentIndex < totalQuestionPages - 1)
					selectPage(model.currentQuestionPages.getItemAt(currentIndex + 1) as ArrayCollection);
			}
		}

		public function selectLastPage():void
		{
			if (totalQuestionPages > 0)
				selectPage(model.currentQuestionPages.getItemAt(totalQuestionPages - 1) as ArrayCollection);
		}

		public function back():void
		{

			PageManager.selectPage("HomePage");

			model.isInProgress=false;

			timerControl.stop();
		}

		public function finishTest():void
		{

			//belezimo rezultate testa
			var answeredQuestions:int=0;
			var correctlyAnswered:int=0;
			var incorrectlyAnswered:int=0;
			var unansweredQuestions:Array=[]; //of questions

			for each (var question:Question in model.filteredQuestions)
			{

				if (question.isAnswered)
				{

					answeredQuestions++;

					if (question.isCorrectlyAnswered())
						correctlyAnswered++;
					else
						incorrectlyAnswered++;
				}
				else
				{

					unansweredQuestions.push(question);
				}
			}

			var popup:TestResultsControl=new TestResultsControl();

			PopUpManager.addPopUp(popup, view, true);
			PopUpManager.centerPopUp(popup);

			popup.setData(model.filteredQuestions.length, answeredQuestions, correctlyAnswered, incorrectlyAnswered);
		}

		private function get totalQuestionPages():int
		{

			return model.currentQuestionPages ? model.currentQuestionPages.length : 0;
		}

		public function selectNextQuestion():void
		{

			var index:int=model.currentQuestions.getItemIndex(model.selectedQuestion);

			if (index < model.currentQuestions.length - 1)
				selectQuestion(model.currentQuestions.getItemAt(index + 1) as Question);
		}

		public function selectPreviousQuestion():void
		{

			var index:int=model.currentQuestions.getItemIndex(model.selectedQuestion);

			if (index > 0)
				selectQuestion(model.currentQuestions.getItemAt(index - 1) as Question);
		}

		public function loginUser(user:User):void
		{

			Settings.user=user;

			PageManager.selectPage("HomePage");

			loadQuestions();
		}

		private function loadQuestions():void
		{

			model.isLoadingQuestions=true;

			if (!questionsLoadingDialog){
				
				questionsLoadingDialog=new QuestionLoadingDialog();
			}
			
			questionsLoadingDialog.start();

			PopUpManager.addPopUp(questionsLoadingDialog, view, true);
			PopUpManager.centerPopUp(questionsLoadingDialog);

			view.serviceGetAllQuestions.send();
		}

		public function selectQuestion(question:Question):void
		{

			model.selectedQuestion=question;

			//sada treba da cuvamo informaciju o citanju pitanja
			if (!model.isTestingMode)
			{

				saveQuestionLearning();
			}

		}

		private function saveQuestionLearning():void
		{

			if (!model.selectedQuestion)
				return;

			//ako smo vec sacuvali ovo pitanje u toku ove sesije ne cuvamo ga opet
			if (model.selectedQuestion.id in model.learningSavedQuestions)
				return;

			//cuvamo ucenje pitanja samo ako ono traje duze od odredjenog vremena
			if (_learningTimer && _learningTimer.running)
				_learningTimer.reset();

			if (!_learningTimer)
			{

				_learningTimer=new Timer(1000, 1);
				_learningTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onLearningTimerComplete);
			}

			_learningTimer.start();
		}

		protected function onLearningTimerComplete(event:TimerEvent):void
		{

			//resetujemo timer da moze opet da se koristi
			_learningTimer.reset();

			if (!model.selectedQuestion)
				return;

			view.serviceSaveLearning.send({questionId: model.selectedQuestion.id, sessionUid: model.learningSessionUID});
			//trace("SAVING LEARNING...");

			model.learningSavedQuestions[model.selectedQuestion.id]=model.selectedQuestion;
		}

		public function selectPageFirstQuestion():void
		{

			if (model.currentQuestions && model.currentQuestions.length > 0)
				selectQuestion(model.currentQuestions.getItemAt(0) as Question);
		}

		public function saveQuestionTestingStat(question:Question):void
		{

			if (!question)
				return;

			var isUpdate:Boolean=false;

			//ako smo vec sacuvali ovo pitanje u toku ove sesije onda radimo update
			if (question.id in model.testingSavedQuestions)
				isUpdate=true;

			view.serviceSaveTesting.send({questionId: model.selectedQuestion.id, isCorrect: question.isCorrectlyAnswered(), isUpdate: isUpdate, sessionUid: model.testingSessionUID});
			//trace("SAVING TESTING...");

			model.testingSavedQuestions[question.id]=question;
		}

	}
}
