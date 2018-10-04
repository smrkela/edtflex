package
{
	import com.evola.driving.controls.QuestionLoadingDialog;
	import com.evola.driving.controls.TimerControl;
	import com.evola.driving.model.Question;
	import com.evola.driving.model.User;
	import com.evola.driving.util.CommonsSettings;
	import com.evola.driving.util.EvolaDrivingModel;
	import com.evola.driving.util.PageManager;
	import com.evola.driving.views.pages.HomePage;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.managers.IBrowserManager;
	import mx.managers.PopUpManager;

	[Bindable]
	public class MainPresenter
	{

		public var model:EvolaDrivingModel=new EvolaDrivingModel();
		public var view:EvolaDrivingTesting;
		public var timerControl:TimerControl;
		public var homePage:HomePage;
		public var browserManager:IBrowserManager;

		//timer za cuvanje zadataka pri ucenju
		private var _learningTimer:Timer;

		public var questionsLoadingDialog:QuestionLoadingDialog;

		public function MainPresenter(view:EvolaDrivingTesting)
		{

			this.view=view;

			//podesavamo save handler
			CommonsSettings.testingSaveHandler = saveQuestionTestingStat;
		}

		public function startLearningSimple():void
		{
			
			model.startLearningSimple();
		}

		public function startTestingSimple():void
		{
			
			model.startTestingSimple();
		}

		public function back():void
		{

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
