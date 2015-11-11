// reset scheduled elements
function clear_sched_element()
{
	evalCol = String(self.element_collection);
	if ( evalCol != 'undefined' )
	{		
		for(i=0;i<self.element_collection.length;i++)
		{
			sitem = self.element_collection[i];
			sp = 'sched_elements_' + sitem.ctrl + '_' + sitem.id;
			document.getElementById(sp).style.display = sitem.display;
		}
	}	
}

// handle scheduled element links
function show_sched_element(eid)
{
	evalCol = String(self.element_collection);
	dispFlag = false;

	if ( evalCol != 'undefined' )
	{		
		for(i=0;i<self.element_collection.length;i++)
		{
			
			sitem = self.element_collection[i];
			sp = 'sched_elements_' + sitem.ctrl + '_' + sitem.id;
			obj = document.getElementsByName(sp);

			if ( sitem.id == eid && obj != null)
			{
				
				dispFlag = true;
				if ( obj.length > 0 )
				{
					for(z=0;z<obj.length;z++)
					{
						obj(z).style.display = 'block';
					}
				}
				else 
					document.getElementById(sp).style.display = 'block';
				
				for (j=0;j < self.element_collection.length;j++){
					if (sitem.ctrl == self.element_collection[j].ctrl && i != j){
						sp = 'sched_elements_' + self.element_collection[j].ctrl + '_' + self.element_collection[j].id;
						obj = document.getElementsByName(sp);

						if ( obj != null )
						{
							if ( obj.length > 0 )
							{	
								for(z=0;z<obj.length;z++)
								{
									obj(z).style.display = 'none';
								}
							}
							else
								document.getElementById(sp).style.display = 'none';
						}
					}
				}
			}
		}
	}

	if ( !dispFlag )
		alert("You do not have access to the requested element.");
}
