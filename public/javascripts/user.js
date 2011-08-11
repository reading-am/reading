$(function(){
  flows.find('a.watch').click(function(){
		var $this = $(this),
			watch = 'watch',
			disabled = 'disabled';
			
		if($this.hasClass(disabled)) return false; //Don't take any action if it's already waiting on a call to return
		
		$this.addClass(disabled);
		$.get($this.attr('href'), function(data){
			if(data == "true"){
				var text = $this.text() == watch ? "un"+watch : watch,
					href = $this.attr('href');
				$this
					.attr('href', href.replace($this.text(), text))
					.text(text);
			}
			$this.removeClass(disabled);
		});
		return false;
	});
});
