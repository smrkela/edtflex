package com.evola.driving.controls.spinner
{
	import mx.core.Container;
	import mx.core.UIComponent;

	public class SpinnerUtil
	{
		public static function showSpinner(parentContainer:Container, color:uint=0xFFFFFF, alpha:Number=1):void
		{

			//ako kontejner vec ima spinner ne postavljamo ga opet
			if (findSpinner(parentContainer))
				return;

			var spinnerCanvas:SpinnerContainer=new SpinnerContainer();

			parentContainer.rawChildren.addChild(spinnerCanvas);
			spinnerCanvas.parentContainer=parentContainer;
		}

		public static function removeSpinner(parentContainer:Container):void
		{
			var spinner:SpinnerContainer=findSpinner(parentContainer);

			if (spinner)
			{
				parentContainer.rawChildren.removeChild(spinner);
				spinner.parentContainer=null;
			}
		}

		private static function findSpinner(container:Container):SpinnerContainer
		{
			for (var i:int=0; i < container.rawChildren.numChildren; i++)
			{
				var child:*=container.rawChildren.getChildAt(i);

				if (child is SpinnerContainer)
				{
					return child as SpinnerContainer;
				}
			}

			return null;
		}
	}
}
