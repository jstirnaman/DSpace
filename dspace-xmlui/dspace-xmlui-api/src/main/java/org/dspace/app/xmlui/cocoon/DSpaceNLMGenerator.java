/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.cocoon;

import java.io.IOException;
import java.sql.SQLException;

import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.ResourceNotFoundException;
import org.apache.cocoon.generation.AbstractGenerator;
import org.dspace.app.xmlui.utils.ContextUtil;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.ItemIterator;
import org.dspace.content.Collection;
import org.dspace.content.crosswalk.CrosswalkException;
import org.dspace.content.crosswalk.DisseminationCrosswalk;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.PluginManager;
import org.dspace.handle.HandleManager;
import org.jdom.DocType;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.output.SAXOutputter;
import org.xml.sax.DTDHandler;
import org.xml.sax.EntityResolver;
import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXException;

/**
 * Generate an NLM aggregation of a DSpace Item. The object to be rendered should be an item identified by pasing 
 * in one of the two parameters: handle or internal. 

 * @author Alexey Maslov
 * @contributor Jason Stirnaman
 */


public class DSpaceNLMGenerator extends AbstractGenerator
{
	
	public void generate() throws IOException, SAXException,
			ProcessingException {
		try {
			// Grab the context.
			Context context = ContextUtil.obtainContext(objectModel);
            				
              DSpaceObject dso = getDSpaceObject(context);
              if (!(dso.getType() == Constants.COLLECTION || dso.getType() == Constants.ITEM))
              {
                  // The handle is valid but the object is not a container.
                  throw new ResourceNotFoundException("Unable to perform NLM dissemination for "+dso.getHandle()+". NLM crosswalk is only valid for Collections and Items.");
              }
 
              // Instantiate and execute the NLM plugin
              
              SAXOutputter out = new SAXOutputter(contentHandler);
              out.setReportDTDEvents(true);
              out.setFeature("validation", true);
              DisseminationCrosswalk xwalk = (DisseminationCrosswalk)PluginManager.getNamedPlugin(DisseminationCrosswalk.class,"nlm");

              //Set the DocType and root element
              DocType nlmtype = new DocType("ArticleSet", "-//NLM//DTD PubMed 2.0//EN","http://www.ncbi.nlm.nih.gov:80/entrez/query/static/PubMed.dtd");
              Element nlmroot = new Element(nlmtype.getElementName());
              
              // Create a document with root element and DTD for the Article list.
              Document nlmdoc = new Document(nlmroot,nlmtype);
              
              // Make sure we have the real root element to add content to
              nlmroot = nlmdoc.getRootElement();
              
              if (dso.getType() == Constants.COLLECTION)
              {   
            	  Collection collection = (Collection) dso;
            	  
                  if (collection.getItems() == null)
                  {
                      throw new ResourceNotFoundException("Unable to locate items for collection.");
                  }
                  
              	ItemIterator iterator = collection.getItems();
               
                // Crosswalk metadata for each item in the collection
                try
                {
                    while (iterator.hasNext())
                    {
                        Item item = iterator.next(); 
                        Element nlm = xwalk.disseminateElement(item);
  	                    
                        // Use JDOM to insert crosswalked metadata for the item into the parent element
  	                    nlmroot.addContent(nlm);                        
                    }
                }
                finally
                {
                    if (iterator != null)
                    {
                        iterator.close();
                    }
                }
              }
              else if (dso.getType() == Constants.ITEM)
              {
                  Item item = (Item) dso;
                  
            	  if (item == null)
                  {
                      throw new ResourceNotFoundException("Unable to locate item.");
                  }                
                  Element nlm = xwalk.disseminateElement(item);
                  nlmroot.addContent(nlm);
              }	
               nlmroot.addContent("<doctype>"+nlmtype.toString()+"</doctype>");
               // Output the result
               out.output(nlmdoc);
			
		} catch (JDOMException je) {
			throw new ProcessingException(je);
		} catch (AuthorizeException ae) {
			throw new ProcessingException(ae);
		} catch (CrosswalkException ce) {
			throw new ProcessingException(ce);
		} catch (SQLException sqle) {
			throw new ProcessingException(sqle);
		}
	}
	
	private DSpaceObject getDSpaceObject(Context context) throws SQLException, CrosswalkException 
	{			
        // Determine the correct adatper to use for this item
        String handle = parameters.getParameter("handle",null);
        String internal = parameters.getParameter("internal",null);
        
		 if (handle != null)
         {
			// Specified using a regular handle. 
         	DSpaceObject dso = HandleManager.resolveToObject(context, handle);         	
            return dso;
         }
         else if (internal != null)
         {
        	// Internal identifier, format: "type:id".
         	String[] parts = internal.split(":");
         	
         	if (parts.length == 2)
         	{
         		String type = parts[0];
         		int id = Integer.valueOf(parts[1]);         		
                return DSpaceObject.find(context,Constants.getTypeID(type),id);        		
         	}
         }
		 return null;
	}	
}
