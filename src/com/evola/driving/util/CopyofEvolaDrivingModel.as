package com.evola.driving.util
{
	import com.evola.driving.model.DrivingCategory;
	import com.evola.driving.model.Question;
	import com.evola.driving.model.QuestionAnswer;
	import com.evola.driving.model.QuestionCategory;

	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.managers.IBrowserManager;

	[Bindable]
	public class CopyOfEvolaDrivingModel
	{

		//kategorije pitanja
		public var questionCategories:ArrayCollection;

		//kategorije pitanja ukljucujuci sve
		public var questionCategoriesIncludingAll:ArrayCollection;

		//kategorije vozila
		public var drivingCategories:ArrayCollection;

		//kategorije vozila ukljucujuci sve
		public var drivingCategoriesIncludingAll:ArrayCollection;

		//sva pitanja
		public var questions:ArrayCollection;

		//pitanja ovog usera s obzirom na njegovu kategoriju
		public var userQuestions:ArrayCollection;

		//da li je trenutno testiranje
		public var isTestingMode:Boolean=true;

		//izabrana kategorija pitanja
		public var currentQuestionCategory:QuestionCategory;

		//izabrana kategorija vozila
		public var currentDrivingCategory:DrivingCategory;

		//filtrirana pitanja koja odgovoaraju trenutnim kriterijumima
		public var filteredQuestions:ArrayCollection;

		//pitanja koja se nalaze na trenutnoj stranici
		public var currentQuestions:ArrayCollection;

		//grupe pitanja tj. stranice sa pitanjima
		public var currentQuestionPages:ArrayCollection;

		//da li je ucenje ili testiranje u toku
		public var isInProgress:Boolean=false;

		//da li da se odgovori prikazuju odmah po odgovoranju
		public var useQuickResponse:Boolean;

		//izabrani broj pitanja za testiranje
		public var currentNumberOfQuestions:int;

		//izabrani flag za nasumicni odabir pitanja
		public var currentRandomizeQuestions:Boolean;

		//trenutno izabrano pitanje
		public var selectedQuestion:Question;

		//da li da se prikazu informacije o tacnosti odgovora posle izvrsenog testiranja
		public var testFinished:Boolean=false;

		//id-evi pitanja koja su sacuvana u toku jedne sesije ucenja
		public var learningSavedQuestions:Object={};

		//uid sesije ucenja
		public var learningSessionUID:String;

		//id-evi pitanja koja su sacuvana u toku jedne sesije testiranja
		public var testingSavedQuestions:Object={};

		//uid sesije testiranja
		public var testingSessionUID:String;

		//da li je ucitavanje pitanja u toku
		public var isLoadingQuestions:Boolean;

		private var _cacheQuestionCategories:Object={};

		private var _cacheDrivingCategories:Object={};

		public function CopyOfEvolaDrivingModel()
		{
		}

		public function getQuestionCategory(id:String):QuestionCategory
		{

			var cat:QuestionCategory=_cacheQuestionCategories[id];

			if (cat)
				return cat;

			for each (var c:QuestionCategory in questionCategories)
			{

				if (c.categoryId == id)
				{
					cat=c;
					break;
				}
			}

			_cacheQuestionCategories[id]=cat;

			return cat;
		}

		public function getDrivingCategory(id:String):DrivingCategory
		{

			var cat:DrivingCategory=_cacheDrivingCategories[id];

			if (cat)
				return cat;

			for each (var c:DrivingCategory in drivingCategories)
			{

				if (c.categoryId == id)
				{
					cat=c;
					break;
				}
			}

			_cacheDrivingCategories[id]=cat;

			return cat;
		}

		public function afterDataLoaded():void
		{

			//sada formiramo i nizove including all
			questionCategoriesIncludingAll=new ArrayCollection();
			var qcAll:QuestionCategory=new QuestionCategory();
			qcAll.categoryId=QuestionCategory.ALL;
			qcAll.name="Sve";
			questionCategoriesIncludingAll.addItem(qcAll);
			questionCategoriesIncludingAll.addAll(questionCategories);

			drivingCategoriesIncludingAll=new ArrayCollection();
			drivingCategoriesIncludingAll.addItem(DrivingCategory.CATEGORY_ALL);
			drivingCategoriesIncludingAll.addAll(drivingCategories);

			//sada dodeljujemo globalni redni broj svakom pitanju
			//prvo pitanja sortiramo

			var sort:Sort=new Sort();
			sort.compareFunction=normalCompareFunction;
			questions.sort=sort;
			questions.refresh();

			var startingGlobalNumber:int=1;
			//prolazimo kroz sva pitanja i dodeljujemo im broj
			for each (var q:Question in questions)
			{

				q.globalNumber=startingGlobalNumber++;

				//usput popunjavamo koliko tacnih odgovora ima pitanje
				var num:int=0;

				if (q.answers)
				{

					for each (var qa:QuestionAnswer in q.answers)
					{

						if (qa.correct)
							num++;
					}
				}

				q.numOfCorrectAnswers=num;
			}

			fillUserQuestions();
		}

		public function fillUserQuestions():void
		{

			var filterFunction:Function=function(item:Question, fields:Array=null):Boolean
			{

				if (item.isInDrivingCategory(Settings.user.drivingCategory))
					return true;

				return false;
			};

			var uq:ArrayCollection=null;

			if (questions)
			{

				uq=new ArrayCollection(questions.source);

				if (Settings.user.drivingCategory)
					uq.filterFunction=filterFunction;

				var sort:Sort=new Sort();
				sort.compareFunction=normalCompareFunction;
				uq.sort=sort;

				uq.refresh();
			}

			userQuestions=uq;
		}

		private function normalCompareFunction(a:Question, b:Question, fields:Array=null):int
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

		public function getQuestion(questionId:String):Question
		{

			for each (var q:Question in questions)
			{

				if (q.id == questionId)
					return q;
			}

			return null;
		}

	}
}
